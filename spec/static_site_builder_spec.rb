require_relative '../build'

RSpec.describe StaticSiteBuilder do
  it "can be instantiated" do
    builder = StaticSiteBuilder.new
    expect(builder).to be_a(StaticSiteBuilder)
  end
end