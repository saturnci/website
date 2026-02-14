class SiteSource
  attr_reader :path

  def initialize(path, environment: 'development', root_path: '.', pages: [])
    @path = path
    @root_path = root_path
    @environment = environment
    @pages = pages
    @layouts_dir = File.join(path, 'layouts')
    @pages_dir = File.join(path, 'pages')
    @assets_dir = File.join(path, 'assets')
  end

  def pages
    @filtered_pages ||= filter_pages(@pages)
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
    Dir.glob(File.join(@root_path, 'CNAME')).select { |f| File.exist?(f) }
  end
end
