---
title: 首页
layout: default
pagination:
  enabled: true
---

# 个人知识库

欢迎来到我的个人知识库！这里存储了我在学习和工作中积累的知识和经验。

## 最近更新

{% for post in paginator.posts %}
### [{{ post.title }}]({{ post.url | relative_url }})
{{ post.date | date: "%Y-%m-%d" }} · {% for cat in post.categories %}`{{ cat }}`{% unless forloop.last %} · {% endunless %}{% endfor %}

{{ post.excerpt }}
{% endfor %}

{% if paginator.total_pages > 1 %}
<div class="pagination">
  {% if paginator.previous_page %}
    <a href="{{ paginator.previous_page_path }}" class="btn">← 上一页</a>
  {% else %}
    <span class="btn" style="opacity:0.5;cursor:not-allowed;">← 上一页</span>
  {% endif %}
  
  <span style="line-height:2.2;">第 {{ paginator.page }} 页 / 共 {{ paginator.total_pages }} 页</span>
  
  {% if paginator.next_page %}
    <a href="{{ paginator.next_page_path }}" class="btn">下一页 →</a>
  {% else %}
    <span class="btn" style="opacity:0.5;cursor:not-allowed;">下一页 →</span>
  {% endif %}
</div>
{% endif %}

## 分类

{% for category in site.categories %}
- [{{ category[0] }}]({{ site.baseurl }}/categories/#{{ category[0] | slugize }})
{% endfor %}

## 标签

{% for tag in site.tags %}
- [{{ tag[0] }}]({{ site.baseurl }}/tags/#{{ tag[0] | slugize }})
{% endfor %}
