# SPDX-License-Identifier: AGPL-3.0-or-later
# PowerShell script for SearXNG management
# For full functionality, use WSL or Git Bash with the ./manage script

param(
    [Parameter(Position=0)]
    [string]$Command = "help",

    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

# Get the script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

# Set up virtual environment path
$VenvDir = Join-Path $ScriptDir ".venv"
$ClientDir = Join-Path $ScriptDir "client\simple"

function Test-NodeInstalled {
    try {
        $nodeVersion = node --version 2>&1
        $npmVersion = npm --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Found: Node $nodeVersion, npm $npmVersion" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "WARNING: Node.js is not installed or not in PATH" -ForegroundColor Yellow
        Write-Host "Theme static files will not be built. Install Node.js from https://nodejs.org/" -ForegroundColor Yellow
        return $false
    }
    return $false
}

function Test-PythonInstalled {
    try {
        $version = python --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Found: $version" -ForegroundColor Green

            # Check version >= 3.10
            $versionMatch = $version -match 'Python (\d+)\.(\d+)'
            if ($versionMatch) {
                $major = [int]$Matches[1]
                $minor = [int]$Matches[2]

                if ($major -lt 3 -or ($major -eq 3 -and $minor -lt 10)) {
                    Write-Host "ERROR: Python 3.10 or later is required. You have $version" -ForegroundColor Red
                    return $false
                }
            }
            return $true
        }
    }
    catch {
        Write-Host "ERROR: Python is not installed or not in PATH" -ForegroundColor Red
        Write-Host "Please install Python 3.10 or later from https://www.python.org/" -ForegroundColor Yellow
        return $false
    }
    return $false
}

function Show-Help {
    Write-Host ""
    Write-Host "SearXNG Management Script (PowerShell)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Available commands:" -ForegroundColor Yellow
    Write-Host "  help            - Show this help message"
    Write-Host "  pyenv.install   - Create virtual environment and install dependencies"
    Write-Host "  pyenv.cmd       - Run a command in the virtual environment"
    Write-Host "  theme.build     - Build theme static files (requires Node.js)"
    Write-Host "  theme.check     - Check if theme static files are up to date"
    Write-Host "  webapp.run      - Run the development server"
    Write-Host "  py.clean        - Clean up virtual environment and build artifacts"
    Write-Host "  test.py         - Run Python tests"
    Write-Host ""
    Write-Host "Note: For full functionality on Windows, consider using:" -ForegroundColor Yellow
    Write-Host "  - WSL (Windows Subsystem for Linux) with the ./manage script"
    Write-Host "  - Git Bash with the ./manage script"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\manage.ps1 pyenv.install"
    Write-Host "  .\manage.ps1 theme.build"
    Write-Host "  .\manage.ps1 webapp.run"
    Write-Host "  .\manage.ps1 pyenv.cmd python -m searx.version"
    Write-Host ""
}

function Install-PyEnv {
    Write-Host "Creating virtual environment..." -ForegroundColor Cyan

    if (-not (Test-Path $VenvDir)) {
        python -m venv $VenvDir
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Failed to create virtual environment" -ForegroundColor Red
            return $false
        }
    }

    Write-Host "Installing dependencies..." -ForegroundColor Cyan
    $activateScript = Join-Path $VenvDir "Scripts\Activate.ps1"

    & $activateScript
    Write-Host "Upgrading pip and installing build tools..." -ForegroundColor Yellow
    python -m pip install --upgrade pip setuptools wheel
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to install build tools" -ForegroundColor Red
        return $false
    }
    
    Write-Host "Installing base dependencies from requirements.txt..." -ForegroundColor Yellow
    python -m pip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to install base dependencies" -ForegroundColor Red
        return $false
    }
    
    Write-Host "Installing project in editable mode with test dependencies..." -ForegroundColor Yellow
    python -m pip install --use-pep517 --no-build-isolation -e ".[test]"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to install project" -ForegroundColor Red
        return $false
    }

    Write-Host "Virtual environment created and dependencies installed successfully!" -ForegroundColor Green
    
    # Check and build theme if Node.js is available
    if (Test-NodeInstalled) {
        Write-Host ""
        Write-Host "Building theme static files..." -ForegroundColor Cyan
        Build-Theme
    } else {
        Write-Host ""
        Write-Host "WARNING: Node.js not found. Theme static files not built." -ForegroundColor Yellow
        Write-Host "To build theme: Install Node.js from https://nodejs.org/ and run: .\manage.ps1 theme.build" -ForegroundColor Yellow
    }
    
    return $true
}

function Build-Theme {
    if (-not (Test-NodeInstalled)) {
        Write-Host "ERROR: Node.js is required to build theme static files" -ForegroundColor Red
        Write-Host "Install Node.js from https://nodejs.org/" -ForegroundColor Yellow
        return $false
    }

    if (-not (Test-Path $ClientDir)) {
        Write-Host "ERROR: Client directory not found: $ClientDir" -ForegroundColor Red
        return $false
    }

    Write-Host "Building theme in $ClientDir..." -ForegroundColor Cyan
    Push-Location $ClientDir

    try {
        # Install npm dependencies if node_modules doesn't exist
        if (-not (Test-Path "node_modules")) {
            Write-Host "Installing npm dependencies..." -ForegroundColor Yellow
            npm install
            if ($LASTEXITCODE -ne 0) {
                Write-Host "ERROR: Failed to install npm dependencies" -ForegroundColor Red
                Pop-Location
                return $false
            }
        }

        # Build the theme
        Write-Host "Running npm build..." -ForegroundColor Yellow
        npm run build
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Failed to build theme" -ForegroundColor Red
            Pop-Location
            return $false
        }

        Write-Host "Theme built successfully!" -ForegroundColor Green
        Pop-Location
        return $true
    }
    catch {
        Write-Host "ERROR: Exception during theme build: $_" -ForegroundColor Red
        Pop-Location
        return $false
    }
}

function Test-ThemeBuild {
    $staticDir = Join-Path $ScriptDir "searx\static\themes\simple"
    $manifestFile = Join-Path $staticDir "manifest.json"
    
    if (-not (Test-Path $manifestFile)) {
        Write-Host "Theme not built: manifest.json not found" -ForegroundColor Red
        Write-Host "Run: .\manage.ps1 theme.build" -ForegroundColor Yellow
        return $false
    }

    $cssFile = Join-Path $staticDir "sxng-ltr.min.css"
    $jsFile = Join-Path $staticDir "sxng-core.min.js"
    
    if ((-not (Test-Path $cssFile)) -or (-not (Test-Path $jsFile))) {
        Write-Host "Theme files incomplete" -ForegroundColor Yellow
        Write-Host "Run: .\manage.ps1 theme.build" -ForegroundColor Yellow
        return $false
    }

    Write-Host "Theme static files are present" -ForegroundColor Green
    return $true
}

function Install-PyEnv {
    Write-Host "Creating virtual environment..." -ForegroundColor Cyan

    if (-not (Test-Path $VenvDir)) {
        python -m venv $VenvDir
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Failed to create virtual environment" -ForegroundColor Red
            return $false
        }
    }

    Write-Host "Installing dependencies..." -ForegroundColor Cyan
    $activateScript = Join-Path $VenvDir "Scripts\Activate.ps1"

    & $activateScript
    Write-Host "Upgrading pip and installing build tools..." -ForegroundColor Yellow
    python -m pip install --upgrade pip setuptools wheel
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to install build tools" -ForegroundColor Red
        return $false
    }
    
    Write-Host "Installing base dependencies from requirements.txt..." -ForegroundColor Yellow
    python -m pip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to install base dependencies" -ForegroundColor Red
        return $false
    }
    
    Write-Host "Installing project in editable mode with test dependencies..." -ForegroundColor Yellow
    python -m pip install --use-pep517 --no-build-isolation -e ".[test]"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to install project" -ForegroundColor Red
        return $false
    }

    Write-Host "Virtual environment created and dependencies installed successfully!" -ForegroundColor Green
    
    # Check and build theme if Node.js is available
    if (Test-NodeInstalled) {
        Write-Host ""
        Write-Host "Building theme static files..." -ForegroundColor Cyan
        Build-Theme
    } else {
        Write-Host ""
        Write-Host "WARNING: Node.js not found. Theme static files not built." -ForegroundColor Yellow
        Write-Host "To build theme: Install Node.js from https://nodejs.org/ and run: .\manage.ps1 theme.build" -ForegroundColor Yellow
    }
    
    return $true
}

function Invoke-PyEnvCmd {
    $activateScript = Join-Path $VenvDir "Scripts\Activate.ps1"

    if (-not (Test-Path $activateScript)) {
        Write-Host "ERROR: Virtual environment not found. Run '.\manage.ps1 pyenv.install' first." -ForegroundColor Red
        return $false
    }

    & $activateScript

    if ($Arguments) {
        $cmdString = $Arguments -join " "
        Invoke-Expression $cmdString
    }

    return $true
}

function Start-WebApp {
    $activateScript = Join-Path $VenvDir "Scripts\Activate.ps1"

    if (-not (Test-Path $activateScript)) {
        Write-Host "ERROR: Virtual environment not found. Run '.\manage.ps1 pyenv.install' first." -ForegroundColor Red
        return $false
    }

    Write-Host ""
    Write-Host "Starting SearXNG development server..." -ForegroundColor Cyan
    Write-Host "Open http://127.0.0.1:8888/ in your browser" -ForegroundColor Green
    Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
    Write-Host ""

    & $activateScript

    $env:SEARXNG_DEBUG = "1"
    $env:GRANIAN_RELOAD = "true"
    $env:GRANIAN_RELOAD_IGNORE_WORKER_FAILURE = "true"
    $env:GRANIAN_RELOAD_PATHS = "./searx"
    $env:GRANIAN_PROCESS_NAME = "searxng"
    $env:GRANIAN_INTERFACE = "wsgi"
    $env:GRANIAN_HOST = "0.0.0.0"
    $env:GRANIAN_PORT = "8888"
    $env:GRANIAN_WEBSOCKETS = "false"
    $env:GRANIAN_BLOCKING_THREADS = "4"
    $env:GRANIAN_WORKERS_KILL_TIMEOUT = "30s"
    $env:GRANIAN_BLOCKING_THREADS_IDLE_TIMEOUT = "5m"

    granian searx.webapp:app
    return $true
}

function Clear-PyEnv {
    Write-Host "Cleaning up virtual environment and build artifacts..." -ForegroundColor Cyan

    $pathsToRemove = @(
        $VenvDir,
        "build",
        "dist",
        "searxng.egg-info",
        ".tox"
    )

    foreach ($path in $pathsToRemove) {
        if (Test-Path $path) {
            Remove-Item -Recurse -Force $path
            Write-Host "Removed: $path" -ForegroundColor Gray
        }
    }

    # Clean Python cache files
    Get-ChildItem -Path . -Directory -Filter "__pycache__" -Recurse | Remove-Item -Recurse -Force
    Get-ChildItem -Path . -File -Filter "*.pyc" -Recurse | Remove-Item -Force
    Get-ChildItem -Path . -File -Filter "*.pyo" -Recurse | Remove-Item -Force

    Write-Host "Cleanup completed!" -ForegroundColor Green
    return $true
}

function Start-Tests {
    $activateScript = Join-Path $VenvDir "Scripts\Activate.ps1"

    if (-not (Test-Path $activateScript)) {
        Write-Host "ERROR: Virtual environment not found. Run '.\manage.ps1 pyenv.install' first." -ForegroundColor Red
        return $false
    }

    & $activateScript
    Write-Host "Running Python tests..." -ForegroundColor Cyan
    pytest tests/

    return $true
}

# Main execution
if (-not (Test-PythonInstalled)) {
    exit 1
}

switch ($Command.ToLower()) {
    "help" {
        Show-Help
    }
    "--help" {
        Show-Help
    }
    "-h" {
        Show-Help
    }
    "pyenv.install" {
        $result = Install-PyEnv
        if (-not $result) { exit 1 }
    }
    "pyenv.cmd" {
        $result = Invoke-PyEnvCmd
        if (-not $result) { exit 1 }
    }
    "theme.build" {
        $result = Build-Theme
        if (-not $result) { exit 1 }
    }
    "theme.check" {
        $result = Test-ThemeBuild
        if (-not $result) { exit 1 }
    }
    "webapp.run" {
        $result = Start-WebApp
        if (-not $result) { exit 1 }
    }
    "py.clean" {
        $result = Clear-PyEnv
        if (-not $result) { exit 1 }
    }
    "test.py" {
        $result = Start-Tests
        if (-not $result) { exit 1 }
    }
    default {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Write-Host "Use '.\manage.ps1 help' for available commands" -ForegroundColor Yellow
        exit 1
    }
}

exit 0
