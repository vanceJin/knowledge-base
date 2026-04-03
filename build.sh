#!/bin/bash

# Netlify 构建脚本
# 用于 Jekyll 知识库的生产部署

set -e

echo "=========================================="
echo "开始 Netlify 构建"
echo "=========================================="

# 设置 Ruby 环境
echo "设置 Ruby 环境..."
export RUBY_VERSION="3.1.4"
export JEKYLL_ENV="production"

# 安装依赖
echo "安装依赖..."
bundle config set --local path 'vendor/bundle'
bundle config set --local without 'development:test'
bundle install --jobs=4 --retry=3

# 清理旧的构建文件
echo "清理旧的构建文件..."
rm -rf _site

# 构建站点
echo "构建站点..."
bundle exec jekyll build \
  --config _config.yml \
  --drafts=false \
  --future=false

# 优化构建产物
echo "优化构建产物..."
find _site -type f -name "*.html" -exec sed -i 's/  \+/ /g' {} \;

# 显示构建统计
echo "=========================================="
echo "构建完成！"
echo "=========================================="
echo "构建文件数量: $(find _site -type f | wc -l)"
echo "构建目录大小: $(du -sh _site | cut -f1)"
echo "=========================================="
