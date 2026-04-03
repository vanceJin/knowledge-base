# Jekyll 知识库 Docker 配置 - 优化版
# 采用多阶段构建,提高安全性和效率

# ============================================
# 阶段1: 构建阶段
# ============================================
FROM jekyll/jekyll:latest AS builder

# 设置工作目录
WORKDIR /srv/jekyll

# 复制项目文件
COPY Gemfile Gemfile.lock ./

# 配置RubyGems源(国内优化)
RUN gem sources --remove https://rubygems.org/ 2>/dev/null || true && \
    gem sources --add https://gems.ruby-china.com/ 2>/dev/null || true

# 安装依赖(利用Docker缓存层)
RUN bundle config set --local path 'vendor/bundle' && \
    bundle config set --local without 'development:test' && \
    bundle install --jobs=4 --retry=3

# 复制剩余项目文件
COPY . .

# 构建站点(生产环境)
RUN JEKYLL_ENV=production bundle exec jekyll build \
    --config _config.yml \
    --drafts=false \
    --future=false

# ============================================
# 阶段2: 运行阶段
# ============================================
FROM nginx:alpine

# 安装必要工具
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# 创建非root用户
RUN addgroup -g 1000 jekyll && \
    adduser -u 1000 -G jekyll -s /bin/sh -D jekyll

# 设置工作目录
WORKDIR /srv/jekyll

# 复制构建产物
COPY --from=builder --chown=jekyll:jekyll /srv/jekyll/_site ./_site

# 复制Nginx配置
COPY --chown=jekyll:jekyll nginx.conf /etc/nginx/conf.d/default.conf

# 设置权限(最小权限原则)
RUN chmod -R 555 /srv/jekyll/_site && \
    chmod -R 444 /srv/jekyll/_site/* 2>/dev/null || true

# 切换到非root用户
USER jekyll

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# 暴露端口
EXPOSE 8080

# 启动Nginx
CMD ["nginx", "-g", "daemon off;"]
