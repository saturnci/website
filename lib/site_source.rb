require 'yaml'

class SiteSource
  def initialize(path, environment: 'development')
    @path = path
    @environment = environment
    @layouts_dir = File.join(path, 'layouts')
    @pages_dir = File.join(path, 'pages')
    @assets_dir = File.join(path, 'assets')
  end

  def pages
    @pages ||= filter_pages(load_pages)
  end

  def filter_pages(pages)
    return pages unless @environment == 'production'
    pages.reject { |page| page[:frontmatter]['draft'] }
  end

  def layout(name)
    File.read(File.join(@layouts_dir, "#{name}.html.erb"))
  end

  def assets
    Dir.glob(File.join(@assets_dir, '*.css')) +
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