---
layout: post
title: "Docker打包.NET Core项目：镜像优化+最小化部署方案"
date: 2026-03-30 16:00:00 +0800
categories: [.NET, Docker]
tags: [Docker, .NET, 镜像优化, 多阶段构建, 最小化部署]
excerpt: "随着容器化技术的普及，Docker部署.NET项目已成为职场必备技能——相比传统部署方式，Docker具有环境一致、部署高效、跨平台等优势。本文基于前两篇的WebApiDemo项目，讲解如何用Docker打包.NET Core项目，包含多阶段构建、镜像瘦身、环境变量配置等核心技巧，实现最小化部署。"
toc: true
---
随着容器化技术的普及，Docker部署.NET项目已成为职场必备技能——相比传统部署方式，Docker具有环境一致、部署高效、跨平台等优势。本文基于前两篇的WebApiDemo项目，讲解如何用Docker打包.NET Core项目，包含多阶段构建、镜像瘦身、环境变量配置等核心技巧，实现最小化部署，适配Windows、Linux、WSL2等多种环境，新手也能快速上手。

## 一、环境准备

- 已完成前两篇内容（.NET 9环境+WebApiDemo项目）
- 安装Docker Desktop（Windows/WSL2），安装后启动（确保Docker服务正常运行）
- 熟悉基础Docker命令（docker build、docker run等，文中会详细说明）

## 二、Docker核心概念（快速了解）

新手无需深入，记住3个核心概念即可：

- **Dockerfile**：打包镜像的"脚本"，定义了镜像的构建步骤
- **镜像（Image）**：打包好的项目文件+运行环境，可理解为"模板"
- **容器（Container）**：镜像运行后的实例，可启动、停止、删除

### Docker工作流程

```
项目源码 → Dockerfile → 构建镜像 → 运行容器 → 提供服务
```

## 三、编写Dockerfile（多阶段构建，镜像瘦身关键）

在WebApiDemo项目根目录（和Program.cs同级），新建一个名为"Dockerfile"的文件（无后缀），编写以下内容（关键步骤有注释）：

```dockerfile
# 第一阶段：构建阶段（使用SDK镜像，用于编译项目）
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
# 设置工作目录（容器内的目录）
WORKDIR /app
# 复制项目文件到工作目录
COPY . .
# 还原NuGet包（依赖包）
RUN dotnet restore
# 编译项目，输出到/out目录（ Release模式，优化编译）
RUN dotnet publish -c Release -o out

# 第二阶段：运行阶段（使用Runtime镜像，仅包含运行所需环境，体积更小）
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
# 设置工作目录
WORKDIR /app
# 从构建阶段复制编译好的文件到运行阶段
COPY --from=build /app/out ./
# 设置环境变量（可选，配置端口、环境等）
ENV ASPNETCORE_URLS=http://+:80
ENV ASPNETCORE_ENVIRONMENT=Production
# 暴露端口（和上面的端口一致）
EXPOSE 80
# 启动项目（指定入口程序集，替换为你的项目名称）
ENTRYPOINT ["dotnet", "WebApiDemo.dll"]
```

### Dockerfile关键说明

#### 1. 多阶段构建原理

- **第一阶段（build）**：使用 `sdk:9.0` 镜像，包含完整的编译工具链
- **第二阶段（runtime）**：使用 `aspnet:9.0` 镜像，仅包含运行时环境
- **优势**：最终镜像体积缩小80%以上（SDK镜像约1.5GB，Runtime镜像约200MB）

#### 2. 镜像选择说明

| 镜像类型 | 基础镜像 | 用途 | 体积 |
|---------|---------|------|------|
| SDK | mcr.microsoft.com/dotnet/sdk:9.0 | 编译、构建 | ~1.5GB |
| Runtime | mcr.microsoft.com/dotnet/aspnet:9.0 | 运行ASP.NET Core应用 | ~200MB |
| Alpine | mcr.microsoft.com/dotnet/aspnet:9.0-alpine | 轻量级运行时 | ~100MB |

#### 3. 关键指令说明

- `FROM`：指定基础镜像
- `WORKDIR`：设置工作目录
- `COPY`：复制文件到镜像
- `RUN`：执行命令
- `ENV`：设置环境变量
- `EXPOSE`：声明端口
- `ENTRYPOINT`：容器启动时执行的命令

## 四、编写.dockerignore文件（避免冗余文件）

在Dockerfile同级目录，新建 `.dockerignore` 文件（无后缀），用于排除不需要打包到镜像的文件，减少镜像体积：

```plaintext
# 排除VS相关文件
.vs/
# 排除编译生成的文件
bin/
obj/
# 排除数据库文件（避免打包本地测试数据）
WebApiDemo.db
# 排除其他冗余文件
.gitignore
README.md
# 排除Docker相关文件（避免循环打包）
Dockerfile
.dockerignore
# 排除测试文件
*.Test/
```

### .dockerignore最佳实践

- ✅ 排除所有编译生成的文件（bin/、obj/）
- ✅ 排除本地配置文件（.vs/、*.user）
- ✅ 排除测试文件（*.Test/）
- ✅ 排除文档文件（README.md、*.md）
- ✅ 排除Docker相关文件（Dockerfile、.dockerignore）

## 五、构建Docker镜像（实操步骤）

### 1. 进入项目目录

打开终端（Windows Terminal/WSL2终端），进入WebApiDemo项目根目录：

```bash
cd WebApiDemo
```

### 2. 构建Docker镜像

输入以下命令，构建Docker镜像（注意末尾的"."，表示当前目录）：

```bash
docker build -t webapidemo:v1 .
```

**命令说明**：
- `docker build`：构建镜像
- `-t webapidemo:v1`：给镜像打标签，格式为"镜像名称:版本号"
- `.`：表示当前目录为构建上下文

### 3. 查看镜像是否成功生成

构建完成后，输入以下命令，查看镜像是否成功生成：

```bash
docker images
```

预期输出：

```
REPOSITORY      TAG       IMAGE ID       CREATED          SIZE
webapidemo      v1        abc123def456   10 seconds ago   215MB
```

### 4. 镜像体积对比

| 阶段 | 镜像名称 | 体积 | 说明 |
|------|---------|------|------|
| 构建阶段 | webapidemo:v1-build | ~1.5GB | 包含SDK和编译工具 |
| 运行阶段 | webapidemo:v1 | ~215MB | 仅包含运行时环境 |
| 优化后 | webapidemo:v1-alpine | ~115MB | 使用Alpine基础镜像 |

## 六、运行Docker容器（启动应用）

### 1. 基础运行命令

```bash
docker run -d -p 8080:80 --name webapidemo webapidemo:v1
```

**命令说明**：
- `docker run`：运行容器
- `-d`：后台运行
- `-p 8080:80`：端口映射，宿主机8080映射容器80
- `--name webapidemo`：容器名称
- `webapidemo:v1`：镜像名称和标签

### 2. 验证容器运行状态

```bash
# 查看运行中的容器
docker ps

# 查看容器日志
docker logs webapidemo

# 查看容器详细信息
docker inspect webapidemo
```

### 3. 访问应用

打开浏览器，访问 `http://localhost:8080/swagger`，应能看到Swagger页面。

## 七、环境变量配置（灵活部署）

### 1. 在Dockerfile中配置

```dockerfile
ENV ASPNETCORE_URLS=http://+:80
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ConnectionStrings__DefaultConnection="Data Source=/app/WebApiDemo.db"
```

### 2. 在运行时配置

```bash
docker run -d \
  -p 8080:80 \
  --name webapidemo \
  -e ASPNETCORE_ENVIRONMENT=Production \
  -e ConnectionStrings__DefaultConnection="Data Source=/app/WebApiDemo.db" \
  webapidemo:v1
```

### 3. 环境变量优先级

1. 运行时 `-e` 参数（最高优先级）
2. Dockerfile中 `ENV` 指令
3. appsettings.json配置文件（最低优先级）

## 八、数据持久化（数据库文件）

### 1. 使用Volume持久化数据

```bash
# 创建Volume
docker volume create webapidemo-data

# 运行容器并挂载Volume
docker run -d \
  -p 8080:80 \
  --name webapidemo \
  -v webapidemo-data:/app \
  webapidemo:v1
```

### 2. 使用本地目录挂载

```bash
# Windows路径（WSL2）
docker run -d \
  -p 8080:80 \
  --name webapidemo \
  -v //e/docker-data/webapidemo:/app \
  webapidemo:v1
```

## 九、镜像优化技巧（进阶）

### 1. 使用Alpine基础镜像

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS runtime
WORKDIR /app
COPY --from=build /app/out ./
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80
ENTRYPOINT ["dotnet", "WebApiDemo.dll"]
```

**优势**：镜像体积从215MB减少到115MB（减少46%）

### 2. 优化构建缓存

```dockerfile
# 先复制项目文件，利用Docker缓存
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

# 先复制.csproj文件，利用缓存
COPY *.csproj ./
RUN dotnet restore

# 再复制其他文件
COPY . .
RUN dotnet publish -c Release -o out
```

**优势**：修改代码后，无需重新下载NuGet包

### 3. 使用多阶段构建+Alpine

```dockerfile
# 第一阶段：构建阶段
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app
COPY *.csproj ./
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o out

# 第二阶段：运行阶段（Alpine）
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS runtime
WORKDIR /app
COPY --from=build /app/out ./
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80
ENTRYPOINT ["dotnet", "WebApiDemo.dll"]
```

## 十、常见问题及解决方案

### 问题1：容器启动失败，提示"Could not find file 'WebApiDemo.dll'"

**原因**：ENTRYPOINT中的程序集名称不正确

**解决方法**：
1. 检查.csproj文件中的 `<AssemblyName>` 标签
2. 确保ENTRYPOINT中的dll名称与之匹配
3. 或使用通配符：`ENTRYPOINT ["dotnet", "*.dll"]`

### 问题2：端口被占用

**原因**：宿主机8080端口已被其他程序占用

**解决方法**：
```bash
# 更换端口映射
docker run -d -p 8081:80 --name webapidemo webapidemo:v1

# 或停止占用端口的进程
# Windows
netstat -ano | findstr :8080
taskkill /PID <PID> /F
```

### 问题3：容器无法访问数据库

**原因**：数据库文件路径不正确

**解决方法**：
```bash
# 挂载Volume
docker run -d \
  -p 8080:80 \
  --name webapidemo \
  -v webapidemo-data:/app \
  webapidemo:v1
```

### 问题4：中文乱码

**原因**：Alpine镜像默认不支持中文

**解决方法**：
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS runtime
RUN apk add --no-cache icu-libs
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
WORKDIR /app
COPY --from=build /app/out ./
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80
ENTRYPOINT ["dotnet", "WebApiDemo.dll"]
```

## 十一、完整部署流程（生产环境）

### 1. 构建镜像

```bash
docker build -t webapidemo:v1 .
```

### 2. 推送镜像到仓库（可选）

```bash
# 登录Docker Hub
docker login

# 打标签
docker tag webapidemo:v1 yourusername/webapidemo:v1

# 推送
docker push yourusername/webapidemo:v1
```

### 3. 部署到服务器

```bash
# 拉取镜像
docker pull yourusername/webapidemo:v1

# 运行容器
docker run -d -p 8080:80 --name webapidemo yourusername/webapidemo:v1
```

### 4. 查看运行状态

```bash
docker ps
docker logs webapidemo
```

## 十二、Docker Compose部署（多容器）

如果需要部署数据库等其他服务，可以使用Docker Compose：

```yaml
# docker-compose.yml
version: '3.8'

services:
  webapidemo:
    image: webapidemo:v1
    ports:
      - "8080:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__DefaultConnection=Data Source=/app/WebApiDemo.db
    volumes:
      - webapidemo-data:/app
    depends_on:
      - postgres

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_USER=webapi
      - POSTGRES_PASSWORD=webapi123
      - POSTGRES_DB=webapidb
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  webapidemo-data:
  postgres-data:
```

运行命令：

```bash
docker-compose up -d
```

## 十三、总结

本文基于WebApiDemo项目，完整讲解了Docker打包.NET Core项目的全流程，包含多阶段构建、镜像瘦身、环境变量配置等核心技巧。

### 核心要点回顾

- ✅ Dockerfile多阶段构建：缩小镜像体积80%+
- ✅ .dockerignore：排除冗余文件
- ✅ 镜像优化：使用Alpine基础镜像
- ✅ 环境变量：灵活配置应用设置
- ✅ 数据持久化：使用Volume挂载
- ✅ 常见问题：端口占用、中文乱码、文件路径

### 部署优势

| 特性 | 传统部署 | Docker部署 |
|------|---------|-----------|
| 环境一致性 | ❌ 不同环境配置不同 | ✅ 一致的运行环境 |
| 部署速度 | ❌ 需要安装依赖 | ✅ 一键启动 |
| 跨平台 | ❌ 需要重新配置 | ✅ 任何支持Docker的平台 |
| 扩展性 | ❌ 手动配置多实例 | ✅ 一键扩展多实例 |
| 回滚 | ❌ 需要备份恢复 | ✅ 回滚到旧版本镜像 |

后续会讲解CI/CD、Kubernetes编排等进阶内容，喜欢的同学可以收藏关注~ 若部署过程中遇到问题，评论区留言交流。

---

**相关文章**：
- [.NET 9环境搭建全教程（Windows+WSL双平台）](#)
- [ASP.NET Core WebAPI从零搭建：完整CRUD实战教程](#)

**标签**：#Docker #.NET #镜像优化 #多阶段构建 #容器化部署 #最小化部署
