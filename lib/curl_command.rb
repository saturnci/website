class CurlCommand
  def initialize(endpoint_data, base_url, auth)
    @endpoint_data = endpoint_data
    @base_url = base_url
    @auth = auth
  end

  def to_s
    endpoint_key = @endpoint_data.keys.first
    method, path = endpoint_key.split(' ', 2)

    "curl -u USER_ID:USER_API_TOKEN #{@base_url}#{path}"
  end
end
