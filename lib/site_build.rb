require 'erb'
require 'fileutils'
require 'ostruct'
require_relative 'syntax_highlighter'
require_relative 'excerpt'

class SiteBuild
  include SyntaxHighlighter

  DEFAULT_OG_DESCRIPTION = "Frustration-free CI built exclusively for Ruby on Rails " \
    "and RSpec. Failure messages front and center, no executable YAML, powered by Docker Compose."

  def initialize(source, output_dir)
    @source = source
    @output_dir = output_dir
  end

  def execute
    clean_output_dir
    copy_assets
    generate_pages
    puts "Site built successfully in #{@output_dir}/"
  end

  def render_page(page, layout_template, all_pages, og_description: DEFAULT_OG_DESCRIPTION)
    content = highlight_code_blocks(page[:content])

    context = OpenStruct.new(
      title: page[:frontmatter]['title'] || 'SaturnCI - Continuous Integration for Ruby on Rails',
      page_title: page[:frontmatter]['page_title'],
      active_nav: page[:frontmatter]['nav'] || page[:filename],
      content: content,
      og_description: og_description,
      pages: all_pages
    )

    # Render the page
    ERB.new(layout_template).result(context.instance_eval { binding })
  end

  def decorate_blog_post_content(content)
    author_blurb = File.read(File.join(@source.path, 'author-blurb.html')).strip
    content = content.sub('<h1>', '<h1 class="blog-post-heading">')
    content = content.sub('</h1>', "</h1>\n  <p class=\"byline\">by Jason Swett</p>")
    content + "\n<p class=\"author-blurb\">#{author_blurb}</p>"
  end

  private

  def blog_post?(page)
    page[:path]&.include?('src/blog/')
  end

  def clean_output_dir
    FileUtils.rm_rf(@output_dir)
    FileUtils.mkdir_p(@output_dir)
  end

  def copy_assets
    @source.assets.each do |asset|
      FileUtils.cp(asset, @output_dir)
    end

    images_output_dir = File.join(@output_dir, 'images')
    FileUtils.mkdir_p(images_output_dir)
    @source.images.each do |image|
      FileUtils.cp(image, images_output_dir)
    end
  end

  def generate_pages
    layout_template = @source.layout('default')
    all_pages = @source.pages

    require_relative 'api_documentation'
    openapi_file = File.join(@source.path, 'openapi.yml')
    formatted_endpoints = APIDocumentation.new(openapi_file).formatted_endpoints
    blog_list_html = blog_post_list_html(all_pages)

    all_pages.each do |page|
      og_description = if blog_post?(page)
        Excerpt.from_html(page[:content])
      else
        DEFAULT_OG_DESCRIPTION
      end

      content = page[:content]
      content = content.gsub('{{endpoints}}', formatted_endpoints) if formatted_endpoints
      content = content.gsub('{{blog_posts}}', blog_list_html)
      content = decorate_blog_post_content(content) if blog_post?(page)

      page_with_content = page.merge(content: content)
      html = render_page(page_with_content, layout_template, all_pages, og_description: og_description)

      output_file = File.join(@output_dir, "#{page[:filename]}.html")
      File.write(output_file, html)
      puts "Generated: #{output_file}"
    end
  end

  def blog_post_list_html(all_pages)
    blog_posts = all_pages.select { |page| blog_post?(page) && !page[:frontmatter]['draft'] }
    links = blog_posts.map { |blog_post|
      title = blog_post[:frontmatter]['page_title'] || blog_post[:filename]
      "<li><a href=\"#{blog_post[:filename]}.html\">#{title}</a></li>"
    }.join("\n")
    "<ul class=\"blog-post-list\">\n#{links}\n</ul>"
  end

end
