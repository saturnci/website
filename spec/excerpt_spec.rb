require_relative '../lib/excerpt'

RSpec.describe Excerpt do
  describe ".from_html" do
    it "strips HTML tags and returns the first 160 characters" do
      html = '<div><h1>My Title</h1><p>This is a <b>great</b> blog post about testing.</p></div>'
      expect(Excerpt.from_html(html)).to eq("My Title This is a great blog post about testing.")
    end

    context "when the content is longer than 160 characters" do
      it "truncates and appends an ellipsis" do
        html = "<p>#{'a' * 200}</p>"
        result = Excerpt.from_html(html)
        expect(result.length).to eq(163)
        expect(result).to end_with("...")
      end
    end
  end
end
