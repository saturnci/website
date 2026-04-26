require 'json'

class CurlCommand
  def initialize(endpoint_data, base_url, auth)
    @endpoint_data = endpoint_data
    @base_url = base_url
    @auth = auth
  end

  def to_s
    endpoint_key = @endpoint_data.keys.first
    method, path = endpoint_key.split(' ', 2)
    request_body = @endpoint_data.values.first['request']

    parts = ['curl', '-H', '"Authorization: Bearer PERSONAL_ACCESS_TOKEN"']
    if method != 'GET'
      parts += ['-X', method]
    end
    if request_body
      parts += ['-H', '"Content-Type: application/json"', '-d', "'#{JSON.generate(request_body)}'"]
    end
    parts << "#{@base_url}#{path}"
    parts.join(' ')
  end
end
