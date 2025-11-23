require 'yaml'
require_relative 'curl_command'

class APIEndpoint
  def initialize(endpoint_yaml)
    @data = YAML.load(endpoint_yaml)
  end

  def to_html
    curl = CurlCommand.new(
      { @data['endpoint_key'] => { 'response' => @data['response'] } },
      @data['base_url'],
      @data['auth']
    ).to_s

    response_yaml = YAML.dump(@data['response'])

    "<hr>\n\n<h2>#{@data['description']}</h2>\n<p><code>#{@data['endpoint_key']}</code></p>\n<pre><code>#{curl}</code></pre>\n<p>Response:</p>\n<pre><code class=\"language-yaml\">#{response_yaml}</code></pre>"
  end
end
