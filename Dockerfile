# Jekyll 知识库 Docker 配置

FROM jekyll/jekyll:latest

# 设置工作目录
WORKDIR /srv/jekyll

# 配置国内RubyGems源
RUN gem sources --remove https://rubygems.org/ && \
    gem sources --add https://gems.ruby-china.com/ && \
    gem sources -l && \
    gem update --system

# 先复制Gemfile和Gemfile.lock
COPY Gemfile Gemfile.lock ./

# 设置权限
RUN chmod -R 777 /srv/jekyll

# 安装依赖
RUN bundle config set --local path 'vendor/bundle' && \
    bundle install --verbose

# 复制其他文件
COPY . .

# 设置权限
RUN chmod -R 777 /srv/jekyll

# 构建站点
RUN jekyll build

# 暴露端口
EXPOSE 4000

# 启动命令 - 支持实时监听
CMD ["jekyll", "serve", "--host", "0.0.0.0", "--watch"]