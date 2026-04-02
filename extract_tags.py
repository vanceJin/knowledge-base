#!/usr/bin/env python3
"""
文章标签和分类自动提取工具
从文章前言部分自动提取分类信息和标签
"""

import re
import json
import os
from pathlib import Path
from typing import Dict, List, Tuple

# 技术关键词词典
TAGS_MAP = {
    '.NET': ['.NET', 'C#', 'ASP.NET', '.NET Core', 'CSharp'],
    '.NET 9': ['.NET 9', 'NET9', '.NET 9.0'],
    'ASP.NET Core': ['ASP.NET Core', 'ASP.NET', 'Core', 'WebAPI'],
    'EF Core': ['EF Core', 'Entity Framework Core', 'EF'],
    'Docker': ['Docker', '容器', '镜像', '容器化', 'docker'],
    'MySQL': ['MySQL', 'mysql', '数据库'],
    'PostgreSQL': ['PostgreSQL', 'Postgres', 'postgres'],
    'Windows': ['Windows', 'Windows', 'Win'],
    'WSL2': ['WSL2', 'WSL', 'Windows Subsystem for Linux'],
    '教程': ['教程', 'tutorial', 'Tutorial', 'guide', 'Guide'],
    '环境配置': ['环境配置', 'environment', 'Environment', 'setup', 'Setup', '安装'],
    '性能优化': ['性能优化', 'performance', 'Performance', '优化', 'optimize', 'Optimize'],
    '数据库对比': ['数据库对比', '对比', 'comparison', 'Comparison'],
    '技术选型': ['技术选型', '选型', 'technology', 'Technology'],
    '入门': ['入门', 'beginner', 'Beginner', '基础', 'basic', 'Basic'],
    'WebAPI': ['WebAPI', 'Web API', 'API'],
    'CRUD': ['CRUD', '增删改查'],
    'Swagger': ['Swagger', 'OpenAPI'],
    '依赖注入': ['依赖注入', 'DI', 'Dependency Injection'],
    'Ollama': ['Ollama', 'ollama'],
    '本地大模型': ['本地大模型', '本地模型', 'LLM', '大模型'],
    'AI对话': ['AI对话', 'AI Chat', '对话', 'Chat'],
    'C#': ['C#', 'CSharp', 'C Sharp'],
    '批量操作': ['批量操作', 'bulk', 'Bulk'],
    '查询优化': ['查询优化', 'query', 'Query', '查询'],
    '索引': ['索引', 'index', 'Index'],
    '镜像优化': ['镜像优化', 'image', 'Image', '优化'],
    '最小化部署': ['最小化部署', 'minimal', 'Minimal', '部署'],
    '多阶段构建': ['多阶段构建', 'multi-stage', 'Multi-stage', '构建'],
    '关系型数据库': ['关系型数据库', 'relational', 'Relational', 'RDBMS'],
}

# 分类映射
CATEGORIES_MAP = {
    '.NET': ['.NET', '.NET 9', 'ASP.NET Core', 'EF Core', 'C#', 'WebAPI', 'CRUD', '依赖注入', '批量操作', '查询优化', '索引'],
    'Docker': ['Docker', '容器', '镜像', '容器化', '多阶段构建', '最小化部署', '镜像优化'],
    '数据库': ['MySQL', 'PostgreSQL', '关系型数据库', '数据库对比', '技术选型', '查询优化', '索引', '批量操作'],
    'AI': ['Ollama', '本地大模型', 'AI对话', 'LLM'],
    '教程': ['教程', '入门', '环境配置']
}


def extract_tags_from_content(content: str) -> List[str]:
    """从内容中提取标签"""
    extracted = []
    content_lower = content.lower()
    
    for tag, keywords in TAGS_MAP.items():
        for kw in keywords:
            if kw.lower() in content_lower or kw in content:
                extracted.append(tag)
                break
    
    return list(set(extracted))


def extract_categories_from_content(content: str) -> List[str]:
    """从内容中提取分类"""
    extracted = []
    content_lower = content.lower()
    
    for category, tags in CATEGORIES_MAP.items():
        for tag in tags:
            if tag.lower() in content_lower or tag in content:
                extracted.append(category)
                break
    
    return list(set(extracted))


def parse_frontmatter(content: str) -> Tuple[Dict, str]:
    """解析 Front Matter"""
    if not content.startswith('---'):
        return {}, content
    
    parts = content.split('---', 2)
    if len(parts) < 3:
        return {}, content
    
    try:
        frontmatter = yaml.safe_load(parts[1]) or {}
    except:
        frontmatter = {}
    
    return frontmatter, parts[2]


def extract_from_post(filepath: str) -> Dict:
    """从文章文件中提取标签和分类"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    frontmatter, body = parse_frontmatter(content)
    
    # 提取标签和分类
    existing_tags = frontmatter.get('tags', [])
    existing_categories = frontmatter.get('categories', [])
    
    extracted_tags = extract_tags_from_content(body)
    extracted_categories = extract_categories_from_content(body)
    
    # 合并结果
    all_tags = list(set(existing_tags + extracted_tags))
    all_categories = list(set(existing_categories + extracted_categories))
    
    return {
        'filepath': filepath,
        'existing_tags': existing_tags,
        'existing_categories': existing_categories,
        'extracted_tags': extracted_tags,
        'extracted_categories': extracted_categories,
        'all_tags': all_tags,
        'all_categories': all_categories
    }


def update_post_file(filepath: str, tags: List[str], categories: List[str]) -> None:
    """更新文章文件的 Front Matter"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    frontmatter, body = parse_frontmatter(content)
    
    # 更新 Front Matter
    frontmatter['tags'] = tags
    frontmatter['categories'] = categories
    
    # 重新构建文件内容
    frontmatter_yaml = yaml.dump(frontmatter, allow_unicode=True, default_flow_style=False)
    new_content = f"---\n{frontmatter_yaml}---\n{body}"
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)


def main():
    """主函数"""
    import yaml
    
    posts_dir = Path('_posts')
    
    if not posts_dir.exists():
        print("错误: 找不到 _posts 目录")
        return
    
    print("=" * 60)
    print("文章标签和分类自动提取工具")
    print("=" * 60)
    
    for post_file in posts_dir.glob('*.md'):
        print(f"\n处理文件: {post_file}")
        
        result = extract_from_post(str(post_file))
        
        print(f"  原有标签: {result['existing_tags']}")
        print(f"  原有分类: {result['existing_categories']}")
        print(f"  提取标签: {result['extracted_tags']}")
        print(f"  提取分类: {result['extracted_categories']}")
        print(f"  合并标签: {result['all_tags']}")
        print(f"  合并分类: {result['all_categories']}")
        
        # 询问是否更新
        if result['extracted_tags'] or result['extracted_categories']:
            update = input("  是否更新 Front Matter? (y/n): ").strip().lower()
            if update == 'y':
                update_post_file(
                    str(post_file),
                    result['all_tags'],
                    result['all_categories']
                )
                print("  ✓ 已更新")
    
    print("\n" + "=" * 60)
    print("处理完成!")
    print("=" * 60)


if __name__ == '__main__':
    import yaml
    main()
