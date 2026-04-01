---
layout: post
title: "如何添加新文章"
date: 2024-01-02 00:00:00 +0800
categories: [教程]
tags: [教程, Markdown]
---

本文介绍如何在知识库中添加新文章。

## 创建文章

1. 在 `_posts` 目录下创建新文件
2. 文件命名格式：`YYYY-MM-DD-title.md`
3. 添加 Front Matter 头部信息

## Front Matter 示例

```markdown
---
layout: post
title: "文章标题"
date: 2024-01-02 00:00:00 +0800
categories: [分类1, 分类2]
tags: [标签1, 标签2, 标签3]
author: Your Name
---

文章内容从这里开始...
```

## Markdown 语法

### 标题
```markdown
# 一级标题
## 二级标题
### 三级标题
```

### 文本格式
```markdown
**粗体** 和 *斜体*
~~删除线~~
```

### 列表
```markdown
- 无序列表项 1
- 无序列表项 2

1. 有序列表项 1
2. 有序列表项 2
```

### 链接和图片
```markdown
[链接文本](https://example.com)
![图片alt](path/to/image.jpg)
```

### 代码块
```markdown
```python
def hello():
    print("Hello, World!")
```
```

### 引用
```markdown
> 这是引用内容
```

## 分类和标签

- **分类**：用于文章的大类划分
- **标签**：用于文章的细粒度标记

## 提示

- 日期格式必须为 `YYYY-MM-DD`
- 标题应简洁明了
- 合理使用分类和标签便于搜索
- 定期整理和归档旧文章

祝你创作愉快！