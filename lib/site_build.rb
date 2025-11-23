require 'erb'
require 'fileutils'
require 'ostruct'
require_relative 'syntax_highlighter'

class SiteBuild
  include SyntaxHighlighter

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

  def render_page(page, layout_template, all_pages)
    content = highlight_code_blocks(page[:content])

    # Create context for ERB template
    context = OpenStruct.new(
      title: page[:frontmatter]['title'] || 'SaturnCI - Continuous Integration for Ruby on Rails',
      page_title: page[:frontmatter]['page_title'],
      active_nav: page[:frontmatter]['nav'] || page[:filename],
      content: content,
      pages: all_pages
    )

    # Render the page
    ERB.new(layout_template).result(context.instance_eval { binding })
  end

  private

  def clean_output_dir
    FileUtils.rm_rf(@output_dir)
    FileUtils.mkdir_p(@output_dir)
  end

  def copy_assets
    @source.assets.each do |asset|
      FileUtils.cp(asset, @output_dir)
    end
  end

  def generate_pages
    layout_template = @source.layout('default')
    all_pages = @source.pages
    openapi_content = @source.openapi_content

    all_pages.each do |page|
      content = page[:content]
      content = content.gsub('{{openapi}}', "<pre>#{openapi_content}</pre>") if openapi_content

      page_with_content = page.merge(content: content)
      html = render_page(page_with_content, layout_template, all_pages)

      # Write to output
      output_file = File.join(@output_dir, "#{page[:filename]}.html")
      File.write(output_file, html)
      puts "Generated: #{output_file}"
    end
  end
end