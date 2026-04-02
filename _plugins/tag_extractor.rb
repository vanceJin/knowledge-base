module Jekyll
  module TagExtractor
    # 技术关键词词典
    TAGS_MAP = {
      '.NET' => ['.NET', 'C#', 'ASP.NET', '.NET Core', 'CSharp'],
      '.NET 9' => ['.NET 9', 'NET9', '.NET 9.0'],
      'ASP.NET Core' => ['ASP.NET Core', 'ASP.NET', 'Core', 'WebAPI'],
      'EF Core' => ['EF Core', 'Entity Framework Core', 'EF'],
      'Docker' => ['Docker', '容器', '镜像', '容器化', 'docker'],
      'MySQL' => ['MySQL', 'mysql', '数据库'],
      'PostgreSQL' => ['PostgreSQL', 'Postgres', 'postgres'],
      'Windows' => ['Windows', 'Windows', 'Win'],
      'WSL2' => ['WSL2', 'WSL', 'Windows Subsystem for Linux'],
      '教程' => ['教程', 'tutorial', 'Tutorial', 'guide', 'Guide'],
      '环境配置' => ['环境配置', 'environment', 'Environment', 'setup', 'Setup', '安装'],
      '性能优化' => ['性能优化', 'performance', 'Performance', '优化', 'optimize', 'Optimize'],
      '数据库对比' => ['数据库对比', '对比', 'comparison', 'Comparison'],
      '技术选型' => ['技术选型', '选型', 'technology', 'Technology'],
      '入门' => ['入门', 'beginner', 'Beginner', '基础', 'basic', 'Basic'],
      'WebAPI' => ['WebAPI', 'Web API', 'API'],
      'CRUD' => ['CRUD', '增删改查'],
      'Swagger' => ['Swagger', 'OpenAPI'],
      '依赖注入' => ['依赖注入', 'DI', 'Dependency Injection'],
      'Ollama' => ['Ollama', 'ollama'],
      '本地大模型' => ['本地大模型', '本地模型', 'LLM', '大模型'],
      'AI对话' => ['AI对话', 'AI Chat', '对话', 'Chat'],
      'C#' => ['C#', 'CSharp', 'C Sharp'],
      'EF Core' => ['EF Core', 'Entity Framework Core'],
      '批量操作' => ['批量操作', 'bulk', 'Bulk'],
      '查询优化' => ['查询优化', 'query', 'Query', '查询'],
      '索引' => ['索引', 'index', 'Index'],
      '镜像优化' => ['镜像优化', 'image', 'Image', '优化'],
      '最小化部署' => ['最小化部署', 'minimal', 'Minimal', '部署'],
      '多阶段构建' => ['多阶段构建', 'multi-stage', 'Multi-stage', '构建'],
      '关系型数据库' => ['关系型数据库', 'relational', 'Relational', 'RDBMS'],
      '数据库对比' => ['数据库对比', 'comparison', 'Comparison', '对比'],
      '技术选型' => ['技术选型', 'technology', 'Technology', '选型']
    }.freeze

    # 分类映射
    CATEGORIES_MAP = {
      '.NET' => ['.NET', '.NET 9', 'ASP.NET Core', 'EF Core', 'C#', 'WebAPI', 'CRUD', '依赖注入', '批量操作', '查询优化', '索引'],
      'Docker' => ['Docker', '容器', '镜像', '容器化', '多阶段构建', '最小化部署', '镜像优化'],
      '数据库' => ['MySQL', 'PostgreSQL', '关系型数据库', '数据库对比', '技术选型', '查询优化', '索引', '批量操作'],
      'AI' => ['Ollama', '本地大模型', 'AI对话', 'LLM'],
      '教程' => ['教程', '入门', '环境配置']
    }.freeze

    # 从内容中提取标签
    def extract_tags_from_content(content)
      extracted = []
      TAGS_MAP.each do |tag, keywords|
        keywords.each do |kw|
          if content.include?(kw)
            extracted << tag
            break
          end
        end
      end
      extracted.uniq
    end

    # 从内容中提取分类
    def extract_categories_from_content(content)
      extracted = []
      CATEGORIES_MAP.each do |category, tags|
        tags.each do |tag|
          if content.include?(tag)
            extracted << category
            break
          end
        end
      end
      extracted.uniq
    end

    # 从 Front Matter 中提取标签（如果已存在）
    def extract_tags_from_frontmatter(frontmatter)
      frontmatter['tags'] || []
    end

    # 从 Front Matter 中提取分类（如果已存在）
    def extract_categories_from_frontmatter(frontmatter)
      frontmatter['categories'] || []
    end

    # 合并提取的标签
    def merge_tags(frontmatter_tags, extracted_tags)
      (frontmatter_tags + extracted_tags).uniq
    end

    # 合并提取的分类
    def merge_categories(frontmatter_categories, extracted_categories)
      (frontmatter_categories + extracted_categories).uniq
    end
  end
end

Liquid::Template.register_filter(Jekyll::TagExtractor)
