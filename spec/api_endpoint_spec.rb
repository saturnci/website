require_relative '../lib/api_endpoint'
require 'yaml'

RSpec.describe APIEndpoint do
  describe "#format_response" do
    it "converts response data to JSON format" do
      response_data = [
        { "id" => "550e8400-e29b-41d4-a716-446655440000", "status" => "Running" }
      ]

      endpoint = APIEndpoint.new("")
      formatted = endpoint.format_response(response_data)

      expected_json = <<~JSON.chomp
        [
          {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "status": "Running"
          }
        ]
      JSON

      expect(formatted).to eq(expected_json)
    end
  end

  let(:endpoint_yaml) do
    <<~YAML
      endpoint_key: "GET /test_suite_runs"
      description: "List test suite runs"
      base_url: "https://app.saturnci.com/api/v1"
      auth: "Basic Auth (USER_ID / USER_API_TOKEN)"
      response:
        - id: "550e8400-e29b-41d4-a716-446655440000"
          status: "Running"
          branch: "main"
    YAML
  end

  it "generates formatted HTML for an endpoint" do
    endpoint = APIEndpoint.new(endpoint_yaml)
    html = endpoint.to_html

    expect(html).to include("<hr>")
    expect(html).to include("<h2>List test suite runs</h2>")
    expect(html).to include("<code>GET /test_suite_runs</code>")
    expect(html).to include("curl -u USER_ID:USER_API_TOKEN")
    expect(html).to include("https://app.saturnci.com/api/v1/test_suite_runs")
    expect(html).not_to include("<code>---\n")
  end

  it "formats the response as JSON" do
    endpoint = APIEndpoint.new(endpoint_yaml)
    html = endpoint.to_html

    expect(html).to include('class="language-json"')
    expect(html).to include('"id": "550e8400-e29b-41d4-a716-446655440000"')
    expect(html).to include('"status": "Running"')
  end
end
