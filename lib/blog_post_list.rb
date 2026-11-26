class BlogPostList
  def initialize(blog_posts)
    @blog_posts = blog_posts
  end

  def to_html
    links = @blog_posts.map { |blog_post|
      title = blog_post[:frontmatter]['page_title'] || blog_post[:filename]
      "<li><a href=\"#{blog_post[:filename]}.html\">#{title}</a></li>"
    }.join("\n")
    "<ul class=\"blog-post-list\">\n#{links}\n</ul>"
  end
end
