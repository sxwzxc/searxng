@echo off
REM SPDX-License-Identifier: AGPL-3.0-or-later
REM Windows batch script for SearXNG management
REM For full functionality, use WSL or Git Bash with the ./manage script

setlocal enabledelayedexpansion

REM Get the script directory
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.10 or later from https://www.python.org/
    exit /b 1
)

REM Check Python version
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
for /f "tokens=1,2 delims=." %%a in ("%PYTHON_VERSION%") do (
    set PYTHON_MAJOR=%%a
    set PYTHON_MINOR=%%b
)

if %PYTHON_MAJOR% LSS 3 (
    echo ERROR: Python 3.10 or later is required. You have Python %PYTHON_VERSION%
    exit /b 1
)
if %PYTHON_MAJOR% EQU 3 if %PYTHON_MINOR% LSS 10 (
    echo ERROR: Python 3.10 or later is required. You have Python %PYTHON_VERSION%
    exit /b 1
)

REM Set up virtual environment path
set "VENV_DIR=%SCRIPT_DIR%.venv"
set "CLIENT_DIR=%SCRIPT_DIR%client\simple"

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    set "NODE_AVAILABLE=0"
) else (
    set "NODE_AVAILABLE=1"
)

if "%1"=="" goto help
if "%1"=="help" goto help
if "%1"=="--help" goto help
if "%1"=="-h" goto help
if "%1"=="pyenv.install" goto pyenv_install
if "%1"=="pyenv.cmd" goto pyenv_cmd
if "%1"=="theme.build" goto theme_build
if "%1"=="theme.check" goto theme_check
if "%1"=="webapp.run" goto webapp_run
if "%1"=="py.clean" goto py_clean
if "%1"=="test.py" goto test_py

echo Unknown command: %1
echo Use "manage.bat help" for available commands
exit /b 1

:help
echo SearXNG Management Script (Windows)
echo.
echo Available commands:
echo   help            - Show this help message
echo   pyenv.install   - Create virtual environment and install dependencies
echo   pyenv.cmd       - Run a command in the virtual environment
echo   theme.build     - Build theme static files (requires Node.js)
echo   theme.check     - Check if theme static files are up to date
echo   webapp.run      - Run the development server
echo   py.clean        - Clean up virtual environment and build artifacts
echo   test.py         - Run Python tests
echo.
echo Note: For full functionality on Windows, consider using:
echo   - WSL (Windows Subsystem for Linux) with the ./manage script
echo   - Git Bash with the ./manage script
echo.
echo Examples:
echo   manage.bat pyenv.install
echo   manage.bat theme.build
echo   manage.bat webapp.run
echo   manage.bat pyenv.cmd python -m searx.version
exit /b 0

:pyenv_install
echo Creating virtual environment...
if not exist "%VENV_DIR%" (
    python -m venv "%VENV_DIR%"
    if errorlevel 1 (
        echo ERROR: Failed to create virtual environment
        exit /b 1
    )
)

echo Installing dependencies...
call "%VENV_DIR%\Scripts\activate.bat"
echo Upgrading pip and installing build tools...
python -m pip install --upgrade pip setuptools wheel
if errorlevel 1 (
    echo ERROR: Failed to install build tools
    exit /b 1
)
echo Installing base dependencies from requirements.txt...
python -m pip install -r requirements.txt
if errorlevel 1 (
    echo ERROR: Failed to install base dependencies
    exit /b 1
)
echo Installing project in editable mode with test dependencies...
python -m pip install --use-pep517 --no-build-isolation -e ".[test]"
if errorlevel 1 (
    echo ERROR: Failed to install project
    exit /b 1
)
echo Virtual environment created and dependencies installed successfully!
echo.
if "%NODE_AVAILABLE%"=="1" (
    echo Building theme static files...
    call :theme_build_internal
) else (
    echo WARNING: Node.js not found. Theme static files not built.
    echo To build theme: Install Node.js from https://nodejs.org/ and run: manage.bat theme.build
)
exit /b 0

:theme_build_internal
if not exist "%CLIENT_DIR%" (
    echo ERROR: Client directory not found: %CLIENT_DIR%
    exit /b 1
)
pushd "%CLIENT_DIR%"
if not exist "node_modules" (
    echo Installing npm dependencies...
    call npm install
    if errorlevel 1 (
        echo ERROR: Failed to install npm dependencies
        popd
        exit /b 1
    )
)
echo Running npm build...
call npm run build
if errorlevel 1 (
    echo ERROR: Failed to build theme
    popd
    exit /b 1
)
echo Theme built successfully!
popd
exit /b 0

:theme_build
if "%NODE_AVAILABLE%"=="0" (
    echo ERROR: Node.js is required to build theme static files
    echo Install Node.js from https://nodejs.org/
    exit /b 1
)
call :theme_build_internal
exit /b %errorlevel%

:theme_check
if not exist "%SCRIPT_DIR%searx\static\themes\simple\manifest.json" (
    echo Theme not built: manifest.json not found
    echo Run: manage.bat theme.build
    exit /b 1
)
if not exist "%SCRIPT_DIR%searx\static\themes\simple\sxng-ltr.min.css" (
    echo Theme files incomplete
    echo Run: manage.bat theme.build
    exit /b 1
)
if not exist "%SCRIPT_DIR%searx\static\themes\simple\sxng-core.min.js" (
    echo Theme files incomplete
    echo Run: manage.bat theme.build
    exit /b 1
)
echo Theme static files are present
exit /b 0

:pyenv_cmd
if not exist "%VENV_DIR%\Scripts\activate.bat" (
    echo ERROR: Virtual environment not found. Run "manage.bat pyenv.install" first.
    exit /b 1
)
call "%VENV_DIR%\Scripts\activate.bat"
shift
%*
exit /b %errorlevel%

:webapp_run
if not exist "%VENV_DIR%\Scripts\activate.bat" (
    echo ERROR: Virtual environment not found. Run "manage.bat pyenv.install" first.
    exit /b 1
)

echo Starting SearXNG development server...
echo Open http://127.0.0.1:8888/ in your browser
echo Press Ctrl+C to stop the server
echo.

call "%VENV_DIR%\Scripts\activate.bat"
set SEARXNG_DEBUG=1
set GRANIAN_RELOAD=true
set GRANIAN_RELOAD_IGNORE_WORKER_FAILURE=true
set GRANIAN_RELOAD_PATHS=./searx
set GRANIAN_PROCESS_NAME=searxng
set GRANIAN_INTERFACE=wsgi
set GRANIAN_HOST=::
set GRANIAN_PORT=8888
set GRANIAN_WEBSOCKETS=false
set GRANIAN_BLOCKING_THREADS=4
set GRANIAN_WORKERS_KILL_TIMEOUT=30s
set GRANIAN_BLOCKING_THREADS_IDLE_TIMEOUT=5m
granian searx.webapp:app
exit /b %errorlevel%

:py_clean
echo Cleaning up virtual environment and build artifacts...
if exist "%VENV_DIR%" rmdir /s /q "%VENV_DIR%"
if exist "build" rmdir /s /q "build"
if exist "dist" rmdir /s /q "dist"
if exist "searxng.egg-info" rmdir /s /q "searxng.egg-info"
if exist ".tox" rmdir /s /q ".tox"

REM Clean Python cache files
for /d /r . %%d in (__pycache__) do @if exist "%%d" rd /s /q "%%d"
for /r . %%f in (*.pyc) do @if exist "%%f" del /q "%%f"
for /r . %%f in (*.pyo) do @if exist "%%f" del /q "%%f"

echo Cleanup completed!
exit /b 0

:test_py
if not exist "%VENV_DIR%\Scripts\activate.bat" (
    echo ERROR: Virtual environment not found. Run "manage.bat pyenv.install" first.
    exit /b 1
)

call "%VENV_DIR%\Scripts\activate.bat"
echo Running Python tests...
pytest tests/
exit /b %errorlevel%
