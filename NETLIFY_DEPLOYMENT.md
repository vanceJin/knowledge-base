# Netlify 部署指南

## 配置说明

### 1. Netlify 配置文件 (netlify.toml)

已配置以下功能：

- **构建命令**: `bundle exec jekyll build`
- **发布目录**: `_site`
- **Ruby 版本**: 3.1.4
- **环境**: production

### 2. 构建优化

- CSS/JS 捆绑和压缩
- HTML 美化
- 图片优化
- 安全头设置
- 缓存策略优化

### 3. 安全设置

- X-Frame-Options: DENY
- X-XSS-Protection: 1; mode=block
- X-Content-Type-Options: nosniff
- Referrer-Policy: strict-origin-when-cross-origin

### 4. 缓存策略

- 静态资源: 1 年缓存
- HTML 文件: 无缓存（必须重新验证）

## 部署步骤

### 方法 1: 通过 Netlify UI

1. 访问 [Netlify](https://app.netlify.com)
2. 点击 "Add new site" → "Import an existing project"
3. 选择您的 Git 仓库
4. 配置构建设置：
   - Build command: `bundle exec jekyll build`
   - Publish directory: `_site`
5. 点击 "Deploy site"

### 方法 2: 通过命令行

1. 安装 Netlify CLI：
   ```bash
   npm install -g netlify-cli
   ```

2. 登录 Netlify：
   ```bash
   netlify login
   ```

3. 部署：
   ```bash
   netlify deploy --prod
   ```

### 方法 3: 通过 Docker

使用生产配置构建并部署：

```bash
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d
```

## 环境变量

在 Netlify Dashboard 中设置以下环境变量：

- `JEKYLL_ENV`: `production`
- `RUBY_VERSION`: `3.1.4`

## 构建脚本

项目包含 `build.sh` 脚本，用于本地构建测试：

```bash
chmod +x build.sh
./build.sh
```

## 本地测试

在本地测试生产构建：

```bash
JEKYLL_ENV=production bundle exec jekyll build
```

## 故障排除

### 构建失败

1. 检查 Ruby 版本是否正确
2. 确认 Gemfile 和 Gemfile.lock 已提交
3. 查看构建日志获取详细错误信息

### 404 错误

1. 检查 `_config.yml` 中的 `baseurl` 设置
2. 确认 `_site` 目录已正确生成

### 样式问题

1. 清理缓存：`bundle exec jekyll clean`
2. 重新构建：`bundle exec jekyll build`

## 性能优化

### 启用 CDN

Netlify 默认启用 CDN，确保静态资源通过 CDN 分发。

### 启用压缩

Netlify 自动启用 Gzip 压缩，无需额外配置。

### 启用 HTTP/2

Netlify 默认支持 HTTP/2，提升加载速度。

## 监控和分析

### 构建状态

在 Netlify Dashboard 中查看构建状态和日志。

### 性能指标

使用 Netlify 的 Site Speed 和 Core Web Vitals 监控性能。

### 访问分析

集成 Google Analytics 或其他分析工具。
