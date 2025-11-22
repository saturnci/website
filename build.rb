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

require_relative 'lib/syntax_highlighter'

class SiteSource
  def initialize(path)
    @path = path
    @layouts_dir = File.join(path, 'layouts')
    @pages_dir = File.join(path, 'pages')
  end

  def pages
    @pages ||= load_pages
  end

  def layout(name)
    File.read(File.join(@layouts_dir, "#{name}.html.erb"))
  end

  def assets
    Dir.glob(File.join(@path, '*.css')) +
    Dir.glob(File.join(@path, 'CNAME')).select { |f| File.exist?(f) }
  end

  private

  def load_pages
    pages = []
    Dir.glob(File.join(@pages_dir, '*.html')).each do |file|
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
      pages << {
        filename: filename,
        frontmatter: frontmatter,
        content: body,
        path: file
      }
    end
    pages
  end
end

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

    @source.pages.each do |page|
      content = highlight_code_blocks(page[:content])

      # Create context for ERB template
      context = OpenStruct.new(
        title: page[:frontmatter]['title'] || 'SaturnCI - Continuous Integration for Ruby on Rails',
        page_title: page[:frontmatter]['page_title'],
        active_nav: page[:frontmatter]['nav'] || page[:filename],
        content: content,
        pages: @source.pages
      )

      # Render the page
      html = ERB.new(layout_template).result(context.instance_eval { binding })

      # Write to output
      output_file = File.join(@output_dir, "#{page[:filename]}.html")
      File.write(output_file, html)
      puts "Generated: #{output_file}"
    end
  end
end

# Build the site
if __FILE__ == $0
  source = SiteSource.new('.')
  build = SiteBuild.new(source, 'public')
  build.execute
end