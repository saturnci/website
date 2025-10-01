#!/usr/bin/env ruby

require 'erb'
require 'yaml'
require 'fileutils'
require 'ostruct'

begin
  require 'rouge'
rescue LoadError
  puts "Rouge gem not found. Install with: gem install rouge"
  exit 1
end

class StaticSiteBuilder
  def initialize
    @layouts_dir = 'layouts'
    @pages_dir = 'pages'
    @output_dir = 'public'
    @pages = []
  end

  def build
    clean_output_dir
    copy_assets
    load_pages
    generate_pages
    puts "Site built successfully in #{@output_dir}/"
  end

  private

  def clean_output_dir
    FileUtils.rm_rf(@output_dir)
    FileUtils.mkdir_p(@output_dir)
  end

  def copy_assets
    # Copy CSS files and other assets
    Dir.glob('*.css').each do |file|
      FileUtils.cp(file, @output_dir)
    end

    # Copy other assets like CNAME, setup.sh, etc.
    %w[CNAME setup.sh].each do |file|
      FileUtils.cp(file, @output_dir) if File.exist?(file)
    end
  end

  def load_pages
    Dir.glob("#{@pages_dir}/*.html").each do |file|
      content = File.read(file)
      if content.start_with?('---')
        parts = content.split('---', 3)
        frontmatter = YAML.load(parts[1])
        body = parts[2].strip
      else
        frontmatter = {}
        body = content
      end

      filename = File.basename(file, '.html')
      @pages << {
        filename: filename,
        frontmatter: frontmatter,
        content: body,
        path: file
      }
    end
  end

  def generate_pages
    layout_template = load_layout('default')

    @pages.each do |page|
      content = highlight_code_blocks(page[:content])

      # Create context for ERB template
      context = OpenStruct.new(
        title: page[:frontmatter]['title'] || 'SaturnCI',
        page_title: page[:frontmatter]['page_title'],
        active_nav: page[:frontmatter]['nav'] || page[:filename],
        content: content,
        pages: @pages
      )

      # Render the page
      html = ERB.new(layout_template).result(context.instance_eval { binding })

      # Write to output
      output_file = "#{@output_dir}/#{page[:filename]}.html"
      File.write(output_file, html)
      puts "Generated: #{output_file}"
    end
  end

  def load_layout(name)
    File.read("#{@layouts_dir}/#{name}.html.erb")
  end

  def highlight_code_blocks(content)
    formatter = Rouge::Formatters::HTML.new(css_class: 'highlight')

    content.gsub(/<pre><code>(.*?)<\/code><\/pre>/m) do |match|
      code = $1.strip

      # Force YAML lexer for now
      lexer = Rouge::Lexer.find('yaml')
      highlighted = formatter.format(lexer.lex(code))

      "<pre class=\"highlight\"><code>#{highlighted}</code></pre>"
    end
  end
end

# Build the site
if __FILE__ == $0
  builder = StaticSiteBuilder.new
  builder.build
end