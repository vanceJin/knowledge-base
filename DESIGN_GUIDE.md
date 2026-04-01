# Jekyll 知识库设计指南

基于行业最佳实践和优秀设计模式的完整设计指南。

## 📚 目录

- [核心设计原则](#核心设计原则)
- [信息架构](#信息架构)
- [导航系统](#导航系统)
- [内容组织](#内容组织)
- [搜索功能](#搜索功能)
- [响应式设计](#响应式设计)
- [性能优化](#性能优化)
- [SEO 优化](#seo-优化)
- [主题定制](#主题定制)
- [插件推荐](#插件推荐)

## 🎯 核心设计原则

### 1. 以用户为中心
- **清晰的信息层级**：确保用户能快速找到所需信息
- **直观的导航**：减少用户学习成本
- **快速的加载速度**：优化用户体验
- **移动端优先**：响应式设计确保多设备兼容

### 2. 简洁性原则
- **内容优先**：避免过多装饰性元素
- **一致的设计**：统一的视觉风格和交互模式
- **减少认知负担**：清晰的界面和明确的指示

### 3. 可维护性
- **模块化设计**：易于更新和扩展
- **清晰的文件结构**：便于团队协作
- **文档完善**：降低维护成本

## 🗂️ 信息架构

### 1. 分类层级设计

**推荐结构（2-3级）**：
```
首页
├── 技术文档
│   ├── 编程语言
│   │   ├── JavaScript
│   │   ├── Python
│   │   └── Ruby
│   ├── 数据库
│   │   ├── MySQL
│   │   ├── PostgreSQL
│   │   └── MongoDB
│   └── 开发工具
│       ├── Docker
│       ├── Git
│       └── CI/CD
├── 教程指南
├── 最佳实践
└── 关于
```

**最佳实践**：
- ✅ **深度控制**：最多 3 级分类，避免过深
- ✅ ** breadth 优先**：每级 5-10 个子分类
- ✅ **清晰命名**：使用用户熟悉的术语
- ✅ **逻辑清晰**：按照使用场景或技术栈组织

### 2. 分类 vs 标签

**分类 (Categories)**：
- 层级结构，支持嵌套
- 用于组织大的内容领域
- 通常用于导航菜单
- 示例：`[技术文档, 编程语言, JavaScript]`

**标签 (Tags)**：
- 扁平结构，无层级
- 用于标记具体内容特征
- 用于内容关联和过滤
- 示例：`[教程, 入门, 实战]`

**使用建议**：
```yaml
# 推荐用法
categories: [技术文档, 数据库, MySQL]  # 用于导航
tags: [数据库对比, MySQL, PostgreSQL, 技术选型]  # 用于关联
```

### 3. 面包屑导航

**实现方式**：
```html
<nav class="breadcrumb">
  <a href="/">首页</a> &gt;
  <a href="/docs/">文档</a> &gt;
  <a href="/docs/database/">数据库</a> &gt;
  <span>MySQL vs PostgreSQL</span>
</nav>
```

**最佳实践**：
- ✅ 最多 4 级层级
- ✅ 包含当前页面
- ✅ 使用语义化 HTML
- ✅ 添加 SEO 元数据

## 🧭 导航系统

### 1. 侧边栏导航

**配置方式**：
```yaml
# _data/navigation.yml
sidebar:
  - title: "入门指南"
    url: /docs/getting-started/
    icon: "fa-rocket"
  - title: "数据库"
    url: /docs/database/
    icon: "fa-database"
    children:
      - title: "MySQL"
        url: /docs/database/mysql/
      - title: "PostgreSQL"
        url: /docs/database/postgresql/
  - title: "开发工具"
    url: /docs/tools/
    icon: "fa-tools"
```

**最佳实践**：
- ✅ 2 级导航为宜
- ✅ 使用图标增强识别
- ✅ 当前页面高亮
- ✅ 折叠/展开功能

### 2. 顶部导航

**推荐结构**：
```
首页 | 文档 | 教程 | 最佳实践 | 关于
```

**最佳实践**：
- ✅ 5-7 个主要菜单项
- ✅ 简洁的命名
- ✅ 下拉菜单不超过 3 级

### 3. 内容关联导航

**相关文章**：
```liquid
{% assign related_posts = site.posts | where: "tags", tag | limit: 5 %}
```

**最佳实践**：
- ✅ 基于标签或分类
- ✅ 显示 3-5 篇相关文章
- ✅ 包含缩略图和摘要

## 🔍 搜索功能

### 1. 全文搜索 (Lunr.js)

**实现方案**：

```javascript
// 搜索索引生成
const documents = [
  {
    "title": "文章标题",
    "url": "/article-url/",
    "content": "文章内容...",
    "tags": ["tag1", "tag2"],
    "categories": ["category1"]
  }
];

// 搜索索引构建
const idx = lunr(function () {
  this.field('title', { boost: 10 });
  this.field('content');
  this.field('tags');
  this.ref('url');
  
  documents.forEach(function (doc) {
    this.add(doc);
  }, this);
});
```

**最佳实践**：
- ✅ 索引字段：title (boost: 10), content, tags
- ✅ 支持模糊搜索
- ✅ 实时搜索建议
- ✅ 搜索结果高亮
- ✅ 搜索历史记录

### 2. 搜索优化

**性能优化**：
- ✅ 使用 `jekyll-lunr-js-search` 插件
- ✅ 生成 `search.json` 索引文件
- ✅ 压缩索引文件
- ✅ 浏览器缓存索引

**用户体验**：
- ✅ 快速响应 (< 200ms)
- ✅ 智能排序（相关性 + 时间）
- ✅ 搜索词高亮
- ✅ 无结果提示

## 📱 响应式设计

### 1. 断点设置

```scss
// _sass/_variables.scss
$breakpoints: (
  'xs': 0,
  'sm': 576px,
  'md': 768px,
  'lg': 992px,
  'xl': 1200px,
  'xxl': 1400px
);

// 常用断点
@media (max-width: 767px) {  // 移动端
  // 移动端样式
}

@media (min-width: 768px) and (max-width: 991px) {  // 平板
  // 平板样式
}

@media (min-width: 992px) {  // 桌面端
  // 桌面端样式
}
```

### 2. 移动端优化

**布局调整**：
- ✅ 单列布局
- ✅ 汉堡菜单
- ✅ 增大点击区域
- ✅ 优化字体大小

**性能优化**：
- ✅ 响应式图片 (`srcset`)
- ✅ 懒加载
- ✅ 减少 HTTP 请求
- ✅ 压缩资源

**触摸交互**：
- ✅ 44x44px 最小点击区域
- ✅ 避免悬停效果
- ✅ 优化滚动体验
- ✅ 快速响应触摸

## ⚡ 性能优化

### 1. 构建优化

**Jekyll 配置**：
```yaml
# _config.yml
incremental: true  # 增量构建
lsi: false         # 关闭相似性搜索
future: false      # 不生成未来日期文章
drafts: false      # 不生成草稿
```

**插件优化**：
- ✅ `jekyll-cache`：缓存生成内容
- ✅ `jekyll-include-cache`：缓存 include 片段
- ✅ 禁用不必要的插件

### 2. 资源优化

**图片优化**：
```html
<!-- 响应式图片 -->
<img 
  src="image.jpg"
  srcset="image-320w.jpg 320w, image-640w.jpg 640w, image-1280w.jpg 1280w"
  sizes="(max-width: 640px) 100vw, 640px"
  alt="描述"
  loading="lazy"
>
```

**CSS/JS 优化**：
- ✅ 压缩和合并
- ✅ 异步加载
- ✅ 移除未使用代码
- ✅ 使用 CDN

### 3. 缓存策略

**浏览器缓存**：
```nginx
# Nginx 配置
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

**服务端缓存**：
- ✅ CDN 缓存静态资源
- ✅ 反向代理缓存
- ✅ Redis 缓存动态内容

## 🔧 SEO 优化

### 1. 元数据标签

**必备标签**：
```html
<!-- 页面标题 -->
<title>文章标题 - 网站名称</title>
<meta name="description" content="文章描述...">
<meta name="keywords" content="关键词1, 关键词2">

<!-- Open Graph -->
<meta property="og:title" content="文章标题">
<meta property="og:description" content="文章描述">
<meta property="og:type" content="article">
<meta property="og:image" content="图片URL">
<meta property="og:url" content="页面URL">

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="文章标题">
<meta name="twitter:description" content="文章描述">
<meta name="twitter:image" content="图片URL">
```

### 2. 结构化数据

**文章结构化数据**：
```json
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "文章标题",
  "description": "文章描述",
  "datePublished": "2026-03-30",
  "dateModified": "2026-03-30",
  "author": {
    "@type": "Person",
    "name": "作者名"
  },
  "publisher": {
    "@type": "Organization",
    "name": "网站名称",
    "logo": {
      "@type": "ImageObject",
      "url": "logo URL"
    }
  }
}
</script>
```

### 3. 站点地图

**生成方式**：
```yaml
# _config.yml
plugins:
  - jekyll-sitemap
```

**最佳实践**：
- ✅ 自动生成 `sitemap.xml`
- ✅ 包含所有页面
- ✅ 更新频率设置
- ✅ 优先级设置

## 🎨 主题定制

### 1. CSS 变量

**主题变量**：
```scss
// _sass/_variables.scss
:root {
  // 主色调
  --primary-color: #3498db;
  --primary-dark: #2980b9;
  --primary-light: #5dade2;
  
  // 文本颜色
  --text-color: #333;
  --text-light: #666;
  --text-dark: #222;
  
  // 背景颜色
  --bg-color: #fff;
  --bg-light: #f8f9fa;
  --bg-dark: #2c3e50;
  
  // 边框颜色
  --border-color: #e0e0e0;
  --border-radius: 8px;
  
  // 间距
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;
  
  // 字体
  --font-family: "Noto Sans SC", -apple-system, BlinkMacSystemFont, sans-serif;
  --font-family-mono: "Courier New", monospace;
  
  // 阴影
  --shadow-sm: 0 2px 4px rgba(0,0,0,0.05);
  --shadow-md: 0 4px 8px rgba(0,0,0,0.1);
  --shadow-lg: 0 8px 16px rgba(0,0,0,0.15);
}

// 深色模式
@media (prefers-color-scheme: dark) {
  :root {
    --bg-color: #1a1a2e;
    --bg-light: #16213e;
    --text-color: #e0e0e0;
    --text-light: #a0a0a0;
    --border-color: #333;
  }
}
```

### 2. 布局组件

**侧边栏**：
```scss
.sidebar {
  @media (min-width: 768px) {
    position: fixed;
    top: 60px;
    left: 20px;
    width: 250px;
    height: calc(100vh - 80px);
    overflow-y: auto;
  }
  
  @media (max-width: 767px) {
    display: none;
  }
}
```

**内容区域**：
```scss
.main-content {
  @media (min-width: 768px) {
    padding-left: 280px;
  }
  
  @media (max-width: 767px) {
    padding: 15px;
  }
}
```

## 🔌 插件推荐

### 1. 官方插件

**jekyll-seo-tag**：
```yaml
# _config.yml
plugins:
  - jekyll-seo-tag
```
- 自动生成 SEO 元数据
- Open Graph 标签
- Twitter Card 标签
- 结构化数据

**jekyll-sitemap**：
```yaml
plugins:
  - jekyll-sitemap
```
- 自动生成 sitemap.xml
- 支持搜索引擎索引

**jekyll-feed**：
```yaml
plugins:
  - jekyll-feed
```
- 生成 RSS/Atom 订阅源

### 2. 第三方插件

**jekyll-lunr-js-search**：
```ruby
# Gemfile
gem 'jekyll-lunr-js-search'
```
- 全文搜索功能
- 客户端搜索
- 模糊匹配

**jekyll-archives**：
```ruby
gem 'jekyll-archives'
```
- 自动生成分类/标签归档页
- 日期归档

**jekyll-include-cache**：
```ruby
gem 'jekyll-include-cache'
```
- 缓存 include 片段
- 提升构建速度

**jekyll-avatar**：
```ruby
gem 'jekyll-avatar'
```
- 显示 GitHub 头像

**jekyll-coffeescript**：
```ruby
gem 'jekyll-coffeescript'
```
- 支持 CoffeeScript

**jekyll-default-layout**：
```ruby
gem 'jekyll-default-layout'
```
- 默认布局设置

**jekyll-readme-index**：
```ruby
gem 'jekyll-readme-index'
```
- README.md 作为首页

**jekyll-redirect-from**：
```ruby
gem 'jekyll-redirect-from'
```
- 重定向页面

**jekyll-relative-links**：
```ruby
gem 'jekyll-relative-links'
```
- 相对链接支持

**jekyll-titles-from-headings**：
```ruby
gem 'jekyll-titles-from-headings'
```
- 从标题生成页面标题

## 📊 最佳实践总结

### 1. 信息架构
- ✅ 2-3 级分类深度
- ✅ 5-10 个子分类每级
- ✅ 清晰的分类命名
- ✅ 分类 vs 标签明确区分

### 2. 导航系统
- ✅ 侧边栏 2 级导航
- ✅ 顶部 5-7 个菜单项
- ✅ 面包屑最多 4 级
- ✅ 相关文章 3-5 篇

### 3. 搜索功能
- ✅ Lunr.js 全文搜索
- ✅ 索引字段优化
- ✅ 实时搜索建议
- ✅ 搜索结果高亮

### 4. 响应式设计
- ✅ 移动端优先
- ✅ 3-4 个断点
- ✅ 44x44px 点击区域
- ✅ 响应式图片

### 5. 性能优化
- ✅ 增量构建
- ✅ 资源压缩
- ✅ 浏览器缓存
- ✅ CDN 加速

### 6. SEO 优化
- ✅ 完整的元数据
- ✅ 结构化数据
- ✅ 自动生成 sitemap
- ✅ RSS 订阅

### 7. 主题定制
- ✅ CSS 变量管理
- ✅ 响应式布局
- ✅ 深色模式
- ✅ 统一视觉风格

## 🚀 快速开始

### 1. 初始化项目
```bash
# 创建新项目
jekyll new my-knowledge-base

# 进入项目目录
cd my-knowledge-base

# 安装依赖
bundle install

# 启动本地服务器
bundle exec jekyll serve --watch
```

### 2. 配置核心插件
```yaml
# _config.yml
plugins:
  - jekyll-seo-tag
  - jekyll-sitemap
  - jekyll-feed
  - jekyll-lunr-js-search
```

### 3. 添加文章
```markdown
---
layout: post
title: "文章标题"
date: 2026-03-30 11:18:00 +0800
categories: [技术文档, 数据库]
tags: [MySQL, PostgreSQL]
toc: true
---

文章内容...
```

### 4. 部署上线
```bash
# 生成静态文件
bundle exec jekyll build

# 部署到 GitHub Pages
git add .
git commit -m "Update site"
git push origin main
```

## 📚 参考资源

### 官方文档
- [Jekyll 官方文档](https://jekyllrb.com/docs/)
- [Jekyll 主题开发](https://jekyllrb.com/docs/themes/)
- [Liquid 模板语言](https://shopify.github.io/liquid/)

### 社区资源
- [Jekyll Talk](https://talk.jekyllrb.com/)
- [Jekyll GitHub](https://github.com/jekyll/jekyll)
- [Awesome Jekyll](https://github.com/planetjekyll/awesome-jekyll-plugins)

### 设计模式
- [Jekyll Style Guide](https://ben.balter.com/jekyll-style-guide/)
- [Just the Docs](https://just-the-docs.github.io/just-the-docs/)
- [Chirpy Theme](https://github.com/cotes2020/jekyll-theme-chirpy)

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

### 提交规范
1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

MIT License

---

**最后更新**: 2026-03-31
