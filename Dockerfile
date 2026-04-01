# Jekyll 知识库 Docker 配置

FROM jekyll/jekyll:latest

# 设置工作目录
WORKDIR /srv/jekyll

# 复制 Gemfile
COPY Gemfile .

# 安装依赖
RUN bundle install

# 暴露端口
EXPOSE 4000

# 启动命令 - 支持实时监听
CMD ["jekyll", "serve", "--host", "0.0.0.0", "--watch"]