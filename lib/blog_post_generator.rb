class BlogPostGenerator
  attr_reader :title

  def initialize(title:)
    @title = title
  end

  def slug
    raise "Title cannot be blank" if title.strip.empty?

    title.downcase.gsub("'", "").gsub(/[^a-z0-9\s]/, " ").gsub(/\s+/, "-")
  end

  def boilerplate
    <<~HTML

      <div class="container page-container">
        <h1>#{title}</h1>

        <div class="page-content">
        </div>
      </div>
    HTML
  end

  def frontmatter
    <<~YAML
      ---
      page_title: #{title}
      nav: #{slug}
      draft: true
      ---
    YAML
  end
end
