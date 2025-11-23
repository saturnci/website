require 'yaml'
require_relative 'api_endpoint'

class APIDocumentation
  def initialize(openapi_file)
    @openapi_file = openapi_file
  end

  def formatted_endpoints
    return nil unless File.exist?(@openapi_file)

    data = YAML.load_file(@openapi_file)

    data['endpoints'].map do |endpoint_key, endpoint_value|
      endpoint_yaml = YAML.dump({
        'endpoint_key' => endpoint_key,
        'description' => endpoint_value['description'],
        'base_url' => data['base_url'],
        'auth' => data['auth'],
        'response' => endpoint_value['response']
      })

      APIEndpoint.new(endpoint_yaml).to_html
    end.join("\n\n")
  end
end
