---
layout: post
title: "2026最新.NET 9环境搭建全教程（Windows+WSL双平台）"
date: 2026-03-30 12:00:00 +0800
categories: [.NET, 环境搭建]
tags: [.NET 9, Windows, WSL2, 环境配置]
excerpt: "作为.NET新手开篇第一篇，先搞定环境搭建这个基础问题——本文适配2026最新.NET 9版本，覆盖Windows本地+WSL2跨平台两种场景，全程实操无废话，包含常见报错解决，新手跟着走就能成功搭建，避免踩坑。"
toc: true
---

作为.NET新手开篇第一篇，先搞定环境搭建这个基础问题——本文适配2026最新.NET 9版本，覆盖Windows本地+WSL2跨平台两种场景，全程实操无废话，包含常见报错解决，新手跟着走就能成功搭建，避免踩坑。适合刚入门.NET、想尝试跨平台开发的同学，收藏起来备用~

## 一、环境准备（提前下载，节省时间）

- **操作系统**：Windows 11（建议，支持WSL2更流畅）/ Windows 10（需开启WSL2支持）

- **必备工具**：
  - .NET 9 SDK（官网最新版，附下载地址）
  - Visual Studio 2022（社区版免费，附安装勾选组件）
  - WSL2（Windows自带，需开启相关功能）
  - 终端工具（Windows Terminal，可选，体验更好）

## 二、Windows平台.NET 9环境搭建（核心步骤）

### 1. 安装.NET 9 SDK

1. 访问 [.NET官网下载页](https://dotnet.microsoft.com/download)，选择"Windows x64 安装程序"，点击下载；

2. 双击安装包，勾选"同意许可条款"，点击"下一步"；

3. 安装完成后，打开终端，输入命令验证：

```bash
dotnet --version
```

预期输出：

```
9.0.xxx
```

### 2. 安装Visual Studio 2022（可选）

1. 访问 [Visual Studio官网](https://visualstudio.microsoft.com/zh-hans/vs/)，下载社区版；

2. 运行安装程序，勾选以下组件：
   - **ASP.NET和Web开发**（必选）
   - **.NET桌面开发**（可选，用于WPF/WinForms）

3. 点击"安装"，等待完成。

### 3. 启用WSL2功能

1. 以管理员身份打开PowerShell，输入：

```powershell
wsl --install
```

2. 重启电脑，等待WSL自动安装完成。

3. 首次启动WSL时，会提示设置用户名和密码。

## 三、WSL2平台.NET 9环境搭建（跨平台适配）

### 1. 安装Ubuntu发行版

1. 打开Microsoft Store，搜索"Ubuntu"；

2. 选择"Ubuntu 22.04 LTS"（推荐）或"Ubuntu 24.04 LTS"；

3. 点击"获取"安装。

### 2. 在WSL中安装.NET 9 SDK

1. 打开Ubuntu终端；

2. 导入微软包签名密钥：

```bash
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
```

3. 更新包列表并安装.NET SDK：

```bash
sudo apt-get update && sudo apt-get install -y dotnet-sdk-9.0
```

4. 验证安装：

```bash
dotnet --version
```

### 3. 安装VS Code（推荐）

1. 在Ubuntu中安装VS Code：

```bash
sudo apt-get install -y code
```

2. 或在Windows中安装VS Code，使用"Remote - WSL"插件连接WSL。

## 四、环境配置优化

### 1. 配置国内镜像源（加速安装）

```bash
# 备份原始源
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

# 使用阿里云镜像
sudo sed -i 's|http://archive.ubuntu.com|http://mirrors.aliyun.com|g' /etc/apt/sources.list
sudo sed -i 's|http://security.ubuntu.com|http://mirrors.aliyun.com|g' /etc/apt/sources.list

# 更新包列表
sudo apt-get update
```

### 2. 配置Git（首次使用）

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 3. 配置SSH密钥（可选）

```bash
# 生成SSH密钥
ssh-keygen -t ed25519 -C "your.email@example.com"

# 启动ssh-agent
eval "$(ssh-agent -s)"

# 添加密钥
ssh-add ~/.ssh/id_ed25519

# 复制公钥到GitHub
cat ~/.ssh/id_ed25519.pub
```

## 五、常见问题及解决方案

### 问题1：dotnet命令找不到

**原因**：PATH环境变量未包含.NET SDK路径

**解决方法**：
```bash
# 临时添加
export PATH=$PATH:/usr/share/dotnet

# 永久添加
echo 'export PATH=$PATH:/usr/share/dotnet' >> ~/.bashrc
source ~/.bashrc
```

### 问题2：中文乱码

**原因**：系统区域设置不正确

**解决方法**：
```bash
# 安装中文语言包
sudo apt-get install -y language-pack-zh-hans

# 设置中文环境
sudo update-locale LANG=zh_CN.UTF-8

# 重启终端
```

### 问题3：权限不足

**原因**：使用sudo安装后，普通用户无权限访问

**解决方法**：
```bash
# 将用户添加到docker组
sudo usermod -aG docker $USER

# 重新登录
```

### 问题4：WSL2网络慢

**原因**：DNS解析问题

**解决方法**：
```bash
# 修改DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
echo "nameserver 114.114.114.114" | sudo tee -a /etc/resolv.conf
```

## 六、验证环境

### 1. 创建测试项目

```bash
# 创建新项目
dotnet new console -n TestApp

# 进入项目目录
cd TestApp

# 运行项目
dotnet run
```

预期输出：

```
Hello, World!
```

### 2. 创建WebAPI项目

```bash
# 创建WebAPI项目
dotnet new webapi -n TestApi

# 进入项目目录
cd TestApi

# 运行项目
dotnet run
```

打开浏览器访问 `https://localhost:7001/weatherforecast`，应能看到JSON响应。

## 七、总结

本文完整讲解了.NET 9在Windows和WSL2双平台的环境搭建流程，包含：

- ✅ Windows平台：SDK安装、VS2022配置、WSL2启用
- ✅ WSL2平台：Ubuntu安装、.NET SDK安装、环境优化
- ✅ 常见问题：路径配置、中文乱码、权限问题、网络优化
- ✅ 环境验证：创建测试项目、运行WebAPI

新手按照本文步骤操作，即可快速搭建完整的.NET开发环境。后续文章会讲解WebAPI开发、Docker部署等进阶内容，欢迎收藏关注~

---

**相关文章**：
- [ASP.NET Core WebAPI从零搭建：完整CRUD实战教程](#)
- [Docker打包.NET Core项目：镜像优化+最小化部署方案](#)

**标签**：#.NET 9 #Windows #WSL2 #环境配置 #入门指南
