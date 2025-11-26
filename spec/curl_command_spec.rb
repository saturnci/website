require_relative '../lib/curl_command'

RSpec.describe CurlCommand do
  let(:endpoint_data) do
    {
      "GET /test_suite_runs" => {
        "description" => "List test suite runs",
        "response" => [
          { "id" => "550e8400-e29b-41d4-a716-446655440000", "status" => "Running" }
        ]
      }
    }
  end

  let(:base_url) { "https://app.saturnci.com/api/v1" }
  let(:auth) { "Basic Auth (USER_ID / USER_API_TOKEN)" }

  it "generates a curl command for a GET endpoint" do
    curl = CurlCommand.new(endpoint_data, base_url, auth)
    expected = "curl -u USER_ID:USER_API_TOKEN https://app.saturnci.com/api/v1/test_suite_runs"

    expect(curl.to_s).to eq(expected)
  end
end
