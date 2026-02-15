# SearXNG - Windows 安装和使用指南

[English](README.rst) | 简体中文

SearXNG 是一个免费的元搜索引擎，不会追踪或分析用户行为，保护用户隐私。

## 关于 Windows 支持

SearXNG 主要针对 Linux/Unix 系统设计，但现在也可以在 Windows 上原生运行。本指南将帮助您在 Windows 系统上安装和运行 SearXNG。

## 系统要求

- **操作系统**: Windows 10/11 (64位)
- **Python**: 3.10 或更高版本
- **Node.js**: 18.0 或更高版本 (用于构建主题静态文件)
- **内存**: 至少 2GB RAM
- **磁盘空间**: 至少 500MB 可用空间
- **可选**: Git for Windows (用于版本管理)

## 快速开始

### 1. 安装 Python

1. 访问 [Python 官网](https://www.python.org/downloads/)
2. 下载 Python 3.10 或更高版本的 Windows 安装程序
3. 运行安装程序时，**务必勾选** "Add Python to PATH" 选项
4. 完成安装后，打开命令提示符(CMD)或 PowerShell，验证安装：
   ```cmd
   python --version
   ```
   应该显示 Python 3.10.x 或更高版本

### 1.5. 安装 Node.js (必需)

1. 访问 [Node.js 官网](https://nodejs.org/)
2. 下载 LTS 版本 (推荐 18.0 或更高版本)
3. 运行安装程序，使用默认设置
4. 完成安装后，验证安装：
   ```cmd
   node --version
   npm --version
   ```
   应该显示 Node.js 和 npm 的版本号

**重要提示**: Node.js 是必需的，用于构建搜索界面的主题和静态文件（CSS、JavaScript、图标等）。如果没有 Node.js，界面将无法正常显示。

### 2. 下载 SearXNG

您可以通过以下方式获取 SearXNG：

**方式 A: 使用 Git (推荐)**
```cmd
git clone https://github.com/searxng/searxng.git
cd searxng
```

**方式 B: 下载 ZIP 文件**
1. 访问 https://github.com/searxng/searxng
2. 点击 "Code" -> "Download ZIP"
3. 解压到您选择的目录
4. 打开命令提示符，进入解压后的目录

### 3. 安装依赖

在 SearXNG 目录中运行：

**使用命令提示符 (CMD):**
```cmd
manage.bat pyenv.install
```

**或使用 PowerShell (推荐):**
```powershell
.\manage.ps1 pyenv.install
```

这个命令会：
- 创建 Python 虚拟环境
- 安装所有必需的 Python 依赖包
- **自动构建主题静态文件**（如果检测到 Node.js）
- 首次运行可能需要几分钟时间

**如果没有安装 Node.js**，您会看到警告信息。请先安装 Node.js，然后运行：
```cmd
manage.bat theme.build
```

### 3.5. 检查主题构建状态（可选）

如果您想确认主题文件是否正确构建，可以运行：

**使用命令提示符:**
```cmd
manage.bat theme.check
```

**使用 PowerShell:**
```powershell
.\manage.ps1 theme.check
```

### 4. 运行 SearXNG

安装完成后，启动开发服务器：

**使用命令提示符 (CMD):**
```cmd
manage.bat webapp.run
```

**或使用 PowerShell (推荐):**
```powershell
.\manage.ps1 webapp.run
```

现在可以在浏览器中访问：
- **主页**: http://localhost:8888
- **本地网络访问**: http://[您的IP地址]:8888

按 `Ctrl+C` 停止服务器。

## 配置 SearXNG

### 配置文件位置

在 Windows 上，SearXNG 的配置文件默认位于：

```
%PROGRAMDATA%\searxng\
```

通常是：
```
C:\ProgramData\searxng\
```

### 创建自定义配置

1. 创建配置目录（如果不存在）：
   ```cmd
   mkdir %PROGRAMDATA%\searxng
   ```

2. 复制默认配置文件：
   ```cmd
   copy searx\settings.yml %PROGRAMDATA%\searxng\settings.yml
   ```

3. 使用文本编辑器（如记事本或 VS Code）编辑配置文件：
   ```cmd
   notepad %PROGRAMDATA%\searxng\settings.yml
   ```

### 常用配置项

在 `settings.yml` 中，您可以修改：

```yaml
# 服务器设置
server:
  port: 8888
  bind_address: "0.0.0.0"  # 允许外网访问，改为 "127.0.0.1" 仅本地访问
  secret_key: "更改为一个随机字符串"  # 重要：用于会话安全

# 搜索设置
search:
  safe_search: 0  # 0: 关闭, 1: 中等, 2: 严格
  autocomplete: ""  # 自动完成建议来源

# UI 设置
ui:
  default_locale: "zh-CN"  # 默认语言
  theme_args:
    simple_style: auto  # 主题: auto, light, dark
```

## 可用命令

SearXNG 提供了两种 Windows 管理脚本：

### manage.bat (命令提示符)

| 命令 | 说明 |
|------|------|
| `manage.bat help` | 显示帮助信息 |
| `manage.bat pyenv.install` | 创建虚拟环境并安装依赖 |
| `manage.bat pyenv.cmd <命令>` | 在虚拟环境中执行命令 |
| `manage.bat theme.build` | 构建主题静态文件 |
| `manage.bat theme.check` | 检查主题文件状态 |
| `manage.bat webapp.run` | 运行开发服务器 |
| `manage.bat py.clean` | 清理虚拟环境和构建文件 |
| `manage.bat test.py` | 运行 Python 测试 |

### manage.ps1 (PowerShell，推荐)

| 命令 | 说明 |
|------|------|
| `.\manage.ps1 help` | 显示帮助信息 |
| `.\manage.ps1 pyenv.install` | 创建虚拟环境并安装依赖 |
| `.\manage.ps1 pyenv.cmd <命令>` | 在虚拟环境中执行命令 |
| `.\manage.ps1 theme.build` | 构建主题静态文件 |
| `.\manage.ps1 theme.check` | 检查主题文件状态 |
| `.\manage.ps1 webapp.run` | 运行开发服务器 |
| `.\manage.ps1 py.clean` | 清理虚拟环境和构建文件 |
| `.\manage.ps1 test.py` | 运行 Python 测试 |

### 使用示例

**使用命令提示符 (CMD):**
```cmd
# 查看帮助
manage.bat help

# 安装依赖
manage.bat pyenv.install

# 构建主题（如果安装时未构建）
manage.bat theme.build

# 检查主题状态
manage.bat theme.check

# 运行服务器
manage.bat webapp.run

# 在虚拟环境中执行 Python 命令
manage.bat pyenv.cmd python -m searx.version

# 运行测试
manage.bat test.py

# 清理环境
manage.bat py.clean
```

**使用 PowerShell (推荐):**
```powershell
# 查看帮助
.\manage.ps1 help

# 安装依赖
.\manage.ps1 pyenv.install

# 构建主题（如果安装时未构建）
.\manage.ps1 theme.build

# 检查主题状态
.\manage.ps1 theme.check

# 运行服务器
.\manage.ps1 webapp.run

# 在虚拟环境中执行 Python 命令
.\manage.ps1 pyenv.cmd python -m searx.version

# 运行测试
.\manage.ps1 test.py

# 清理环境
.\manage.ps1 py.clean
```

**注意**: 如果 PowerShell 提示执行策略错误，运行：
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 故障排除

### 问题 0: 页面显示异常，图标过大或布局混乱

**症状**: 访问 http://localhost:8888 时，页面布局不正常，图标显示异常大，CSS 样式缺失

**原因**: 主题静态文件（CSS、JavaScript、图标）未构建或构建不完整

**解决方案**:
1. 确认已安装 Node.js：
   ```cmd
   node --version
   ```
   如果未安装，请访问 https://nodejs.org/ 下载安装

2. 构建主题文件：
   ```cmd
   manage.bat theme.build
   ```
   或
   ```powershell
   .\manage.ps1 theme.build
   ```

3. 检查构建状态：
   ```cmd
   manage.bat theme.check
   ```

4. 重新启动服务器：
   ```cmd
   manage.bat webapp.run
   ```

### 问题 1: Python 未找到

**错误信息**: `'python' 不是内部或外部命令`

**解决方案**:
1. 确认 Python 已安装
2. 将 Python 添加到系统 PATH：
   - 右键点击 "此电脑" -> "属性" -> "高级系统设置"
   - 点击 "环境变量"
   - 在 "系统变量" 中找到 "Path"，点击 "编辑"
   - 添加 Python 安装目录（如 `C:\Python310` 和 `C:\Python310\Scripts`）

### 问题 2: 依赖安装失败

**错误信息**: `Failed to build` 或 `error: Microsoft Visual C++ 14.0 is required`

**解决方案**:
1. 安装 Microsoft C++ Build Tools：
   - 访问 https://visualstudio.microsoft.com/visual-cpp-build-tools/
   - 下载并安装 "Build Tools for Visual Studio"
   - 选择 "C++ build tools" 工作负载
2. 或者安装 Visual Studio Community 版本

### 问题 3: 端口被占用

**错误信息**: `Address already in use` 或 `[Errno 10048]`

**解决方案**:
1. 更改端口：编辑配置文件中的 `server.port` 设置
2. 或者停止占用 8888 端口的其他程序：
   ```cmd
   netstat -ano | findstr :8888
   taskkill /PID <进程ID> /F
   ```

### 问题 4: 无法访问搜索引擎

**症状**: SearXNG 运行正常，但搜索无结果

**解决方案**:
1. 检查网络连接
2. 某些搜索引擎可能被防火墙阻止，检查防火墙设置
3. 检查配置文件中启用的搜索引擎列表

### 问题 5: Git 命令不可用

**症状**: 版本信息显示为 "1.0.0"

**说明**: 这是正常的。在 Windows 上，如果没有安装 Git 或 Git 不在 PATH 中，SearXNG 会使用默认版本号。这不影响功能。

**可选解决方案**: 安装 [Git for Windows](https://git-scm.com/download/win) 并确保它在 PATH 中。

## Windows 特定限制

由于 Windows 和 Linux 的差异，以下功能在 Windows 上可能不完全支持：

1. **完整的 ./manage 脚本**: 这是一个 Bash 脚本，需要 Git Bash 或 WSL 才能运行
2. **容器/Docker 功能**: 建议在 Docker Desktop for Windows 中运行
3. **某些构建和测试工具**: 需要 Unix 工具链

### 推荐的 Windows 开发环境

如果需要完整的开发功能，建议使用：

1. **WSL 2 (Windows Subsystem for Linux)**
   - 安装 Ubuntu 或其他 Linux 发行版
   - 在 WSL 中使用标准的 Linux 安装流程
   - 性能更好，功能完整

2. **Git Bash**
   - 随 Git for Windows 一起安装
   - 提供基本的 Unix 命令行工具
   - 可以运行 `./manage` 脚本

3. **Docker Desktop**
   - 使用官方 Docker 镜像运行 SearXNG
   - 最简单的部署方式

### 使用 WSL 2 (推荐)

如果您需要完整的 SearXNG 功能，推荐使用 WSL 2：

1. **启用 WSL 2**:
   ```powershell
   # 在管理员 PowerShell 中运行
   wsl --install
   ```

2. **安装 Ubuntu**:
   ```powershell
   wsl --install -d Ubuntu
   ```

3. **在 WSL 中安装 SearXNG**:
   ```bash
   # 在 WSL Ubuntu 终端中运行
   git clone https://github.com/searxng/searxng.git
   cd searxng
   ./manage pyenv.install
   ./manage webapp.run
   ```

4. **访问**: 仍然可以在 Windows 浏览器中访问 http://localhost:8888

## 生产环境部署

对于生产环境，**不建议**直接在 Windows 上部署 SearXNG。推荐方案：

### 方案 1: 使用 Docker (推荐)

```cmd
# 安装 Docker Desktop for Windows
# 然后运行：
docker pull searxng/searxng
docker run -d -p 8888:8080 ^
  -v "%USERPROFILE%\searxng:/etc/searxng" ^
  --name searxng ^
  searxng/searxng
```

### 方案 2: Linux 服务器

在生产环境中，强烈建议使用 Linux 服务器（如 Ubuntu、Debian）来部署 SearXNG，以获得：
- 更好的性能
- 更高的稳定性
- 完整的功能支持
- 更好的安全性

详细的 Linux 部署指南请参考官方文档：https://docs.searxng.org/admin/installation.html

## 更多资源

- **官方文档**: https://docs.searxng.org/
- **GitHub 仓库**: https://github.com/searxng/searxng
- **问题报告**: https://github.com/searxng/searxng/issues
- **社区讨论**: https://github.com/searxng/searxng/discussions
- **Matrix 聊天室**: #searxng:matrix.org

## 安全建议

1. **更改 secret_key**: 在配置文件中设置一个强随机字符串
2. **使用 HTTPS**: 在生产环境中通过反向代理（如 nginx）配置 HTTPS
3. **限制访问**: 如果不需要公开访问，将 `bind_address` 设置为 `127.0.0.1`
4. **定期更新**: 使用 `git pull` 获取最新的安全更新

## 许可证

SearXNG 使用 GNU Affero General Public License v3.0 (AGPL-3.0) 许可。

详见 [LICENSE](LICENSE) 文件。

## 贡献

欢迎贡献！请查看 [CONTRIBUTING.rst](CONTRIBUTING.rst) 了解如何参与项目开发。

---

**注意**: 本 README 是针对 Windows 用户的补充文档。完整的项目信息请参考 [README.rst](README.rst)。
