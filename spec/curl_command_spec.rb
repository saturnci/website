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
  let(:auth) { "Basic Auth (USER_ID / PERSONAL_ACCESS_TOKEN)" }

  it "generates a curl command for a GET endpoint" do
    curl = CurlCommand.new(endpoint_data, base_url, auth)
    expected = "curl -u USER_ID:PERSONAL_ACCESS_TOKEN https://app.saturnci.com/api/v1/test_suite_runs"

    expect(curl.to_s).to eq(expected)
  end

  context "when the endpoint is a POST with a request body" do
    let(:endpoint_data) do
      {
        "POST /repositories" => {
          "description" => "Create a repository",
          "request" => { "repo_full_name" => "owner/name" },
          "response" => { "id" => "550e8400-e29b-41d4-a716-446655440000" }
        }
      }
    end

    it "includes the method, content type, and request body" do
      curl = CurlCommand.new(endpoint_data, base_url, auth)
      expected = %q(curl -u USER_ID:PERSONAL_ACCESS_TOKEN -X POST -H "Content-Type: application/json" -d '{"repo_full_name":"owner/name"}' https://app.saturnci.com/api/v1/repositories)

      expect(curl.to_s).to eq(expected)
    end
  end
end
