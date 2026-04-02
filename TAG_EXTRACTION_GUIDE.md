# 文章标签和分类自动提取工具使用指南

## 概述

本文档介绍如何使用自动提取工具从文章前言部分提取分类信息和标签，提高内容管理效率。

## 工具组成

### 1. Jekyll 插件（_plugins/tag_extractor.rb）

Jekyll 构建时自动运行的 Ruby 插件，用于在生成页面时提取标签和分类。

**功能特点：**
- 构建时自动提取
- 与 Jekyll 生态无缝集成
- 支持中文和英文关键词匹配

**使用方法：**
1. 确保已安装 Ruby 和 Jekyll
2. 插件会自动在构建时运行
3. 无需额外配置

**关键词词典位置：**
- 文件：`_plugins/tag_extractor.rb`
- 位置：第 10-100 行

### 2. Python 自动提取脚本（extract_tags.py）

独立的 Python 脚本，用于批量处理文章文件并更新 Front Matter。

**功能特点：**
- 批量处理多篇文章
- 交互式确认更新
- 支持手动校验结果

**使用方法：**

```bash
# 安装依赖
pip install pyyaml

# 运行脚本
python extract_tags.py
```

**交互式操作：**
```
处理文件: _posts/2026-03-30-Docker-Packaging-NET-Core-Project.md
  原有标签: ['Docker', '.NET', '镜像优化', '多阶段构建', '最小化部署']
  原有分类: ['.NET', 'Docker']
  提取标签: ['Docker', '.NET', '镜像优化', '多阶段构建', '最小化部署']
  提取分类: ['.NET', 'Docker']
  合并标签: ['Docker', '.NET', '镜像优化', '多阶段构建', '最小化部署']
  合并分类: ['.NET', 'Docker']
  是否更新 Front Matter? (y/n): y
  ✓ 已更新
```

## 关键词词典

### 标签关键词（TAGS_MAP）

| 标签 | 关键词 |
|------|--------|
| .NET | .NET, C#, ASP.NET, .NET Core, CSharp |
| .NET 9 | .NET 9, NET9, .NET 9.0 |
| ASP.NET Core | ASP.NET Core, ASP.NET, Core, WebAPI |
| EF Core | EF Core, Entity Framework Core, EF |
| Docker | Docker, 容器, 镜像, 容器化, docker |
| MySQL | MySQL, mysql, 数据库 |
| PostgreSQL | PostgreSQL, Postgres, postgres |
| Windows | Windows, Windows, Win |
| WSL2 | WSL2, WSL, Windows Subsystem for Linux |
| 教程 | 教程, tutorial, Tutorial, guide, Guide |
| 环境配置 | 环境配置, environment, Environment, setup, Setup, 安装 |
| 性能优化 | 性能优化, performance, Performance, 优化, optimize, Optimize |
| 数据库对比 | 数据库对比, 对比, comparison, Comparison |
| 技术选型 | 技术选型, 选型, technology, Technology |
| 入门 | 入门, beginner, Beginner, 基础, basic, Basic |
| WebAPI | WebAPI, Web API, API |
| CRUD | CRUD, 增删改查 |
| Swagger | Swagger, OpenAPI |
| 依赖注入 | 依赖注入, DI, Dependency Injection |
| Ollama | Ollama, ollama |
| 本地大模型 | 本地大模型, 本地模型, LLM, 大模型 |
| AI对话 | AI对话, AI Chat, 对话, Chat |
| C# | C#, CSharp, C Sharp |
| 批量操作 | 批量操作, bulk, Bulk |
| 查询优化 | 查询优化, query, Query, 查询 |
| 索引 | 索引, index, Index |
| 镜像优化 | 镜像优化, image, Image, 优化 |
| 最小化部署 | 最小化部署, minimal, Minimal, 部署 |
| 多阶段构建 | 多阶段构建, multi-stage, Multi-stage, 构建 |
| 关系型数据库 | 关系型数据库, relational, Relational, RDBMS |

### 分类关键词（CATEGORIES_MAP）

| 分类 | 标签 |
|------|------|
| .NET | .NET, .NET 9, ASP.NET Core, EF Core, C#, WebAPI, CRUD, 依赖注入, 批量操作, 查询优化, 索引 |
| Docker | Docker, 容器, 镜像, 容器化, 多阶段构建, 最小化部署, 镜像优化 |
| 数据库 | MySQL, PostgreSQL, 关系型数据库, 数据库对比, 技术选型, 查询优化, 索引, 批量操作 |
| AI | Ollama, 本地大模型, AI对话, LLM |
| 教程 | 教程, 入门, 环境配置 |

## 添加新关键词

### 在 Jekyll 插件中添加

编辑 `_plugins/tag_extractor.rb` 文件：

```ruby
TAGS_MAP = {
  '新标签' => ['关键词1', '关键词2', '关键词3'],
  # ... 其他标签
}.freeze

CATEGORIES_MAP = {
  '新分类' => ['标签1', '标签2', '标签3'],
  # ... 其他分类
}.freeze
```

### 在 Python 脚本中添加

编辑 `extract_tags.py` 文件：

```python
TAGS_MAP = {
    '新标签': ['关键词1', '关键词2', '关键词3'],
    # ... 其他标签
}

CATEGORIES_MAP = {
    '新分类': ['标签1', '标签2', '标签3'],
    # ... 其他分类
}
```

## 手动维护 Front Matter

即使使用自动提取工具，也建议手动维护 Front Matter，确保准确性：

```yaml
---
layout: post
title: "文章标题"
date: 2026-03-30 16:00:00 +0800
categories:
  - .NET
  - Docker
tags:
  - Docker
  - .NET
  - 镜像优化
  - 多阶段构建
  - 最小化部署
excerpt: "文章摘要"
toc: true
---
```

**最佳实践：**
1. 先使用自动提取工具生成初步结果
2. 手动校验和调整标签和分类
3. 确保分类和标签符合项目规范
4. 定期更新关键词词典

## 故障排除

### 问题1：提取结果不准确

**原因：** 关键词词典不完整

**解决方法：**
1. 检查关键词词典是否包含相关关键词
2. 添加缺失的关键词
3. 重新运行提取工具

### 问题2：Jekyll 插件未运行

**原因：** Ruby 环境未配置或插件文件名错误

**解决方法：**
1. 确保 `_plugins` 目录存在
2. 确保插件文件以 `.rb` 结尾
3. 检查 Ruby 和 Jekyll 是否正确安装

### 问题3：Python 脚本运行报错

**原因：** 缺少依赖包

**解决方法：**
```bash
pip install pyyaml
```

## 高级用法

### 自定义提取规则

可以在插件或脚本中添加自定义规则，例如：

```ruby
# 忽略某些关键词
def extract_tags_from_content(content)
  extracted = []
  TAGS_MAP.each do |tag, keywords|
    next if tag == '忽略的标签'  # 忽略特定标签
    
    keywords.each do |kw|
      if content.include?(kw)
        extracted << tag
        break
      end
    end
  end
  extracted.uniq
end
```

### 批量更新脚本

创建批处理脚本，自动处理所有文章：

```bash
# Windows
for /f %f in ('dir /b _posts\*.md') do (
  python extract_tags.py
)

# Linux/Mac
for file in _posts/*.md; do
  python extract_tags.py
done
```

## 性能优化

### Jekyll 插件优化

1. **缓存关键词词典**：避免重复加载
2. **使用正则表达式**：提高匹配速度
3. **限制处理范围**：只处理修改过的文件

### Python 脚本优化

1. **批量处理**：一次读取所有文件
2. **并行处理**：使用多线程处理多个文件
3. **增量处理**：只处理新增或修改的文件

## 贡献指南

欢迎提交关键词建议：

1. 检查关键词是否已存在
2. 提供关键词的使用场景
3. 提交 Pull Request

## 更新日志

### v1.0.0 (2026-04-02)

- 初始版本发布
- 支持中文和英文关键词匹配
- 提供 Jekyll 插件和 Python 脚本两种方案
