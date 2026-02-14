#!/usr/bin/env ruby

require 'rouge'
require 'yaml'
require_relative 'lib/site_source'
require_relative 'lib/site_build'

def pages_from_directory(dir)
  pages = []
  Dir.glob(File.join(dir, '*.html')).each do |file|
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

# Build the site
if __FILE__ == $0
  environment = ENV['SITE_ENV'] || 'production'
  pages = pages_from_directory('src/pages') + pages_from_directory('src/blog')
  source = SiteSource.new('src', environment: environment, root_path: '.', pages: pages)
  build = SiteBuild.new(source, 'public')
  build.execute
end
