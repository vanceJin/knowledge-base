---
title: 首页
layout: home
pagination:
  enabled: true
---

<h1>个人知识库</h1>

<p>欢迎来到我的个人知识库！这里存储了我在学习和工作中积累的知识和经验。</p>

<h2>最近更新</h2>

{% for post in paginator.posts %}
<h3><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h3>
<p>{{ post.date | date: "%Y-%m-%d" }} · {% for cat in post.categories %}<code>{{ cat }}</code>{% unless forloop.last %} · {% endunless %}{% endfor %}</p>

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

<h2>分类</h2>

<ul>
{% for category in site.categories %}
  <li><a href="{{ site.baseurl }}/categories/#{{ category[0] | slugize }}">{{ category[0] }}</a></li>
{% endfor %}
</ul>

<h2>标签</h2>

<ul>
{% for tag in site.tags %}
  <li><a href="{{ site.baseurl }}/tags/#{{ tag[0] | slugize }}">{{ tag[0] }}</a></li>
{% endfor %}
</ul>
