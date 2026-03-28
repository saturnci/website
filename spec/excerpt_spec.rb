require_relative '../lib/excerpt'

RSpec.describe Excerpt do
  describe ".from_html" do
    it "returns the plain text content without HTML markup" do
      html = '<div><h1>My Title</h1><p>This is a <b>great</b> blog post about testing.</p></div>'

      result = Excerpt.from_html(html)

      expect(result).to eq("My Title This is a great blog post about testing.")
    end

    context "when the content is longer than 160 characters" do
      it "truncates and appends an ellipsis" do
        html = "<p>#{'a' * 200}</p>"

        result = Excerpt.from_html(html)

        expect(result).to end_with("...")
        expect(result.length).to eq(160 + "...".length)
      end
    end
  end
end
