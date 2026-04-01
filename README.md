# Jekyll 知识库系统

基于 Jekyll 和 Docker 构建的个人知识库系统，提供文章发布、分类、标签、搜索等功能。

## 📋 目录

- [功能特点](#功能特点)
- [技术栈](#技术栈)
- [项目结构](#项目结构)
- [快速开始](#快速开始)
- [配置说明](#配置说明)
- [文章编写](#文章编写)
- [自定义主题](#自定义主题)
- [部署指南](#部署指南)
- [维护说明](#维护说明)

## ✨ 功能特点

### 核心功能
- ✅ **静态网站生成** - 基于 Jekyll 的高性能静态网站
- ✅ **Markdown 编写** - 使用 Markdown 语法编写文章
- ✅ **自动目录生成** - 文章内自动生成目录导航
- ✅ **分类与标签** - 文章分类和标签系统
- ✅ **全文搜索** - 基于 lunr.js 的本地搜索
- ✅ **响应式设计** - 支持桌面和移动端访问

### 增强功能
- 📊 **阅读进度指示器** - 顶部实时显示阅读进度
- 📚 **文章目录(TOC)** - 侧边栏固定显示文章目录
- 🔥 **热门文章** - 侧边栏展示热门文章列表
- 📂 **分类导航** - 侧边栏显示分类列表
- 🏷️ **标签云** - 侧边栏显示标签云
- 📤 **文章分享** - 支持分享到社交平台
- 🌙 **深色模式** - 支持深色/浅色主题切换（待实现）
- 🔗 **相关文章** - 文章末尾显示相关文章（待实现）

## 🛠️ 技术栈

### 核心技术
- **Jekyll 4.4.1** - 静态网站生成器
- **Ruby 3.1.1** - 运行环境
- **Liquid** - 模板引擎
- **Markdown (Kramdown)** - 内容格式
- **Sass/CSS** - 样式系统

### 前端技术
- **HTML5** - 语义化标记
- **CSS3** - 现代样式
- **JavaScript (ES6+)** - 交互功能
- **Font Awesome** - 图标库

### 开发工具
- **Docker** - 容器化部署
- **Docker Compose** - 服务编排
- **Bundler** - Ruby 依赖管理

## 📁 项目结构

```
knowledge-base/
├── _config.yml              # Jekyll 配置文件
├── _posts/                  # 文章目录
│   └── 2026-03-30-*.md     # 文章文件（YYYY-MM-DD-title.md）
├── _layouts/                # 布局模板
│   ├── default.html        # 默认布局
│   ├── post.html           # 文章布局
│   ├── page.html           # 页面布局
│   └── home.html           # 首页布局
├── _includes/               # 可复用片段
│   ├── header.html         # 页头
│   ├── footer.html         # 页脚
│   ├── sidebar.html        # 侧边栏
│   ├── toc.html            # 目录
│   ├── share-buttons.html  # 分享按钮
│   ├── reading-progress.html # 阅读进度
│   ├── popular-posts.html  # 热门文章
│   ├── sidebar-categories.html # 分类列表
│   ├── sidebar-tags.html   # 标签云
│   └── sidebar-about.html  # 关于信息
├── _sass/                   # Sass 样式模块
├── assets/                  # 静态资源
│   ├── css/                # 样式文件
│   │   └── style.css       # 主样式文件
│   ├── js/                 # JavaScript 文件
│   └── images/             # 图片资源
├── _site/                   # 生成的网站（自动生成）
├── index.html               # 首页
├── about.html               # 关于页面
├── categories.html          # 分类页面
├── tags.html                # 标签页面
├── Dockerfile               # Docker 配置
├── docker-compose.yml       # Docker Compose 配置
├── Gemfile                  # Ruby 依赖
├── Gemfile.lock             # 依赖锁定
└── README.md                # 项目说明
```

## 🚀 快速开始

### 前置要求
- Docker 已安装
- Docker Compose 已安装

### 本地运行

#### 方法一：使用 Docker Compose（推荐）

```bash
# 进入项目目录
cd knowledge-base

# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

#### 方法二：本地 Ruby 环境

```bash
# 安装依赖
bundle install

# 启动本地服务器
bundle exec jekyll serve --watch
```

### 访问网站
- 本地访问: http://localhost:4000
- 文章目录: http://localhost:4000/posts/
- 分类页面: http://localhost:4000/categories/
- 标签页面: http://localhost:4000/tags/
- 关于页面: http://localhost:4000/about/

## ⚙️ 配置说明

### 基础配置 (`_config.yml`)

```yaml
# 站点基本信息
title: 个人知识库
description: 我的知识管理平台
author: Your Name
lang: zh-CN
timezone: Asia/Shanghai

# URL 设置
url: "http://localhost:4000"
baseurl: ""

# 主题和插件
theme: jekyll-theme-chirpy
plugins:
  - jekyll-feed
  - jekyll-seo-tag

# 侧边栏配置
sidebar:
  - title: "目录"
    icon: "fa-list"
    type: "toc"
  - title: "分类"
    icon: "fa-folder"
    type: "categories"
  - title: "标签"
    icon: "fa-tags"
    type: "tags"
  - title: "关于"
    icon: "fa-user"
    type: "about"

# 搜索设置
search:
  enabled: true
  provider: lunr

# 页脚配置
footer:
  since: 2024
  social: true
  copyright: true
  powered_by: true
```

### 文章 Front Matter

每篇文章顶部需要包含 YAML Front Matter：

```yaml
---
layout: post
title: "文章标题"
date: 2026-03-30 11:18:00 +0800
categories: [数据库技术, MySQL, PostgreSQL]
tags: [数据库对比, MySQL, PostgreSQL, 技术选型]
toc: true
toc_sticky: true
description: "文章描述"
---

文章内容...
```

**字段说明**:
- `layout`: 布局模板（post/page）
- `title`: 文章标题
- `date`: 发布日期（格式：YYYY-MM-DD HH:MM:SS +时区）
- `categories`: 分类列表
- `tags`: 标签列表
- `toc`: 是否显示目录（true/false）
- `toc_sticky`: 目录是否固定（true/false）
- `description`: 文章描述

## ✍️ 文章编写

### 基础格式

```markdown
---
layout: post
title: "文章标题"
date: 2026-03-30 11:18:00 +0800
categories: [分类1, 分类2]
tags: [标签1, 标签2]
---

# 一级标题

正文内容...

## 二级标题

### 三级标题

#### 四级标题

## 代码示例

```javascript
function hello() {
  console.log("Hello, World!");
}
```

## 列表

### 无序列表
- 项目1
- 项目2
- 项目3

### 有序列表
1. 第一步
2. 第二步
3. 第三步

## 引用

> 这是引用内容

## 链接

[链接文本](https://example.com)

## 图片

![图片alt](path/to/image.png)

## 表格

| 列1 | 列2 | 列3 |
|-----|-----|-----|
| 内容1 | 内容2 | 内容3 |
| 内容4 | 内容5 | 内容6 |
```

### 添加目录

在文章中添加目录：

```yaml
---
toc: true
toc_sticky: true
---
```

目录会自动生成，基于文章中的 `##` 和 `###` 标题。

## 🎨 自定义主题

### 修改样式

样式文件位于 `assets/css/style.css`，支持自定义 CSS：

```css
/* 修改链接颜色 */
a {
  color: #3498db;
}

/* 修改标题颜色 */
h1, h2, h3 {
  color: #2c3e50;
}

/* 修改文章内容样式 */
.post-content {
  line-height: 1.8;
}
```

### 修改布局

布局文件位于 `_layouts/` 目录：

- `default.html` - 默认布局
- `post.html` - 文章布局
- `page.html` - 页面布局
- `home.html` - 首页布局

### 添加新页面

创建新页面文件（如 `contact.html`）：

```html
---
layout: page
title: 联系我们
---

<div class="page">
  <h1 class="page-heading">{{ page.title }}</h1>
  
  <div class="post-content">
    <p>联系信息...</p>
  </div>
</div>
```

## 🚢 部署指南

### 部署到 GitHub Pages

1. **推送代码到 GitHub**

```bash
git add .
git commit -m "Update site"
git push origin main
```

2. **配置 GitHub Pages**
   - 进入仓库 Settings → Pages
   - Source 选择 GitHub Actions
   - 保存设置

3. **配置 GitHub Actions**（可选）

创建 `.github/workflows/deploy.yml`：

```yaml
name: Deploy Jekyll site to Pages

on:
  push:
    branches: ["main"]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Jekyll
        uses: jekyll/action@v3
        
      - name: Build site
        run: jekyll build
        
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./_site
```

### 部署到其他静态托管服务

#### Vercel
1. 连接 GitHub 仓库
2. 构建命令: `jekyll build`
3. 输出目录: `_site`

#### Netlify
1. 连接 GitHub 仓库
2. 构建命令: `jekyll build`
3. 输出目录: `_site`

#### Docker 部署
```bash
# 构建镜像
docker build -t knowledge-base .

# 运行容器
docker run -d -p 80:4000 --name knowledge-base knowledge-base
```

## 🔧 维护说明

### 添加新文章

1. 在 `_posts/` 目录创建文件：`YYYY-MM-DD-title.md`
2. 添加 Front Matter 和内容
3. 保存文件
4. Jekyll 会自动重新生成网站

### 清理缓存

```bash
# 删除生成的网站
rm -rf _site

# 重新构建
docker-compose down
docker-compose up -d
```

### 更新依赖

```bash
# 更新 Ruby 依赖
bundle update

# 更新 Docker 镜像
docker-compose pull
docker-compose up -d --build
```

### 备份数据

```bash
# 备份文章和配置
tar -czf backup.tar.gz _posts/ _config.yml assets/
```

## 📝 常见问题

### Q: 如何修改侧边栏内容？
A: 编辑 `_includes/` 目录下的相关文件。

### Q: 如何添加新页面？
A: 在根目录创建新 HTML 文件，添加 `layout: page`。

### Q: 如何启用搜索功能？
A: 在 `_config.yml` 中设置 `search.enabled: true`。

### Q: 如何修改主题颜色？
A: 编辑 `assets/css/style.css` 中的 CSS 变量。

### Q: 如何添加自定义样式？
A: 在 `assets/css/style.css` 中添加自定义 CSS 规则。

## 🤝 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

MIT License

## 🙏 致谢

- [Jekyll](https://jekyllrb.com/) - 静态网站生成器
- [Chirpy Theme](https://github.com/cotes2020/jekyll-theme-chirpy) - 主题模板
- [Docker](https://www.docker.com/) - 容器化技术
