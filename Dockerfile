# Jekyll 知识库 Docker 配置

FROM jekyll/jekyll:latest

# 设置工作目录
WORKDIR /srv/jekyll

# 复制所有文件
COPY . .

# 安装依赖
RUN bundle config set --local path 'vendor/bundle'
RUN bundle install

# 显示构建信息用于调试
RUN bundle exec jekyll build --verbose 2>&1 || true

# 暴露端口
EXPOSE 4000

# 启动命令 - 支持实时监听
CMD ["jekyll", "serve", "--host", "0.0.0.0", "--watch"]