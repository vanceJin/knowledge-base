---
layout: post
title: "欢迎使用个人知识库"
date: 2024-01-01 00:00:00 +0800
categories: [介绍]
tags: [欢迎, 入门]
---

欢迎使用你的个人知识库！

## 功能特点

- **Markdown 支持**：使用 Markdown 格式编写内容
- **分类和标签**：为文章添加分类和标签
- **搜索功能**：内置搜索功能快速查找内容
- **响应式设计**：支持桌面和移动设备
- **Docker 容器化**：一键部署，环境一致

## 快速开始

1. 克隆项目
2. 运行 `docker-compose up -d`
3. 访问 http://localhost:4000
4. 开始创建你的知识库内容！

## 文件结构

```
knowledge-base/
├── _config.yml        # Jekyll 配置
├── _posts/            # 文章目录
├── _layouts/          # 布局模板
├── _includes/         # 模板片段
├── assets/            # 静态资源
├── Dockerfile         # Docker 配置
└── docker-compose.yml # Docker Compose 配置
```

## 开始创作

在 `_posts` 目录下创建新的 Markdown 文件：

```markdown
---
layout: post
title: "文章标题"
date: 2024-01-01 00:00:00 +0800
categories: [分类]
tags: [标签1, 标签2]
---

你的文章内容...
```

祝你使用愉快！