# SearXNG Windows Quick Start Guide

This guide helps you run SearXNG natively on Windows.

## Prerequisites

- Windows 10/11 (64-bit)
- Python 3.10 or later
- Node.js 18.0 or later (required for theme building)
- At least 2GB RAM

## Installation Steps

### 1. Install Python

1. Download Python from https://www.python.org/downloads/
2. **Important**: Check "Add Python to PATH" during installation
3. Verify: `python --version` (should show 3.10+)

### 2. Install Node.js (Required)

1. Download Node.js LTS from https://nodejs.org/
2. Install using default settings
3. Verify: `node --version` and `npm --version`

**Note**: Node.js is required to build theme static files (CSS, JavaScript, icons). Without it, the UI will not display correctly.

### 3. Get SearXNG

**Option A: Using Git**
```cmd
git clone https://github.com/searxng/searxng.git
cd searxng
```

**Option B: Download ZIP**
Download from https://github.com/searxng/searxng and extract.

### 4. Install Dependencies

**Using PowerShell (Recommended):**
```powershell
.\manage.ps1 pyenv.install
```

**Using Command Prompt:**
```cmd
manage.bat pyenv.install
```

This command will:
- Create Python virtual environment
- Install all required dependencies
- **Automatically build theme static files** (if Node.js is detected)

If Node.js is not installed, you'll see a warning. Install Node.js first, then run:
```cmd
manage.bat theme.build
```

### 5. Run SearXNG

**Using PowerShell:**
```powershell
.\manage.ps1 webapp.run
```

**Using Command Prompt:**
```cmd
manage.bat webapp.run
```

Open http://localhost:8888 in your browser!

## Configuration

Configuration files are located in:
```
%PROGRAMDATA%\searxng\
```

Typically: `C:\ProgramData\searxng\`

To customize:
1. Create the directory: `mkdir %PROGRAMDATA%\searxng`
2. Copy default settings: `copy searx\settings.yml %PROGRAMDATA%\searxng\settings.yml`
3. Edit with your preferred text editor

## Available Commands

| Command | Description |
|---------|-------------|
| `help` | Show help |
| `pyenv.install` | Install dependencies |
| `webapp.run` | Run development server |
| `py.clean` | Clean build artifacts |
| `test.py` | Run tests |

## Troubleshooting

### Python not found
- Reinstall Python with "Add to PATH" checked
- Or manually add Python to PATH in System Environment Variables

### Microsoft Visual C++ required
- Install "Build Tools for Visual Studio" from https://visualstudio.microsoft.com/visual-cpp-build-tools/
- Select "C++ build tools" workload

### Port already in use
- Change port in `settings.yml` under `server.port`
- Or stop the process using port 8888

### PowerShell execution policy error
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## For Full Functionality

Consider using:
- **WSL 2**: Run Linux in Windows for complete features
- **Docker Desktop**: Use official Docker image
- **Git Bash**: Run the `./manage` bash script

## Production Deployment

For production use, **use Docker or Linux server**:

```cmd
docker run -d -p 8888:8080 -v "%USERPROFILE%\searxng:/etc/searxng" searxng/searxng
```

## More Information

- Documentation: https://docs.searxng.org/
- GitHub: https://github.com/searxng/searxng
- Chinese Guide: [README.md](README.md)
- Full README: [README.rst](README.rst)

## License

AGPL-3.0-or-later
