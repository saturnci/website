require_relative '../lib/site_source'

RSpec.describe SiteSource do
  it "can be instantiated" do
    source = SiteSource.new('.')
    expect(source).to be_a(SiteSource)
  end
end