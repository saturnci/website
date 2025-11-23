require 'yaml'

class SiteSource
  attr_reader :path

  def initialize(path, environment: 'development', root_path: '.')
    @path = path
    @root_path = root_path
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
    Dir.glob(File.join(@root_path, 'CNAME')).select { |f| File.exist?(f) }
  end

  def openapi_content
    openapi_file = File.join(@path, 'openapi.yml')
    File.exist?(openapi_file) ? File.read(openapi_file) : nil
  end

  def curl_examples
    openapi_file = File.join(@path, 'openapi.yml')
    return nil unless File.exist?(openapi_file)

    require_relative 'curl_command'
    data = YAML.load_file(openapi_file)

    examples = data['endpoints'].map do |endpoint_key, endpoint_value|
      endpoint_data = { endpoint_key => endpoint_value }
      CurlCommand.new(endpoint_data, data['base_url'], data['auth']).to_s
    end

    examples.join("\n\n")
  end

  def formatted_endpoints
    openapi_file = File.join(@path, 'openapi.yml')
    return nil unless File.exist?(openapi_file)

    require_relative 'curl_command'
    data = YAML.load_file(openapi_file)

    data['endpoints'].map do |endpoint_key, endpoint_value|
      endpoint_data = { endpoint_key => endpoint_value }
      curl = CurlCommand.new(endpoint_data, data['base_url'], data['auth']).to_s
      description = endpoint_value['description']
      response_yaml = YAML.dump(endpoint_value['response'])

      "<hr>\n\n<h2>#{description}</h2>\n<p><code>#{endpoint_key}</code></p>\n<pre><code>#{curl}</code></pre>\n<p>Response:</p>\n<pre><code class=\"language-yaml\">#{response_yaml}</code></pre>"
    end.join("\n\n")
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