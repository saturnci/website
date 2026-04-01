require_relative "../lib/blog_post_generator"

RSpec.describe BlogPostGenerator do
  describe "#slug" do
    context "when a valid title is supplied" do
      it "returns a slugified version of the title" do
        generator = BlogPostGenerator.new(title: "My Great Post")
        expect(generator.slug).to eq("my-great-post")
      end
    end

    context "when the title contains an apostrophe" do
      it "strips the apostrophe" do
        generator = BlogPostGenerator.new(title: "Improving on Sandi Metz's Gear Class")
        expect(generator.slug).to eq("improving-on-sandi-metzs-gear-class")
      end
    end

    context "when a blank title is supplied" do
      it "raises an error" do
        generator = BlogPostGenerator.new(title: "")
        expect { generator.slug }.to raise_error("Title cannot be blank")
      end
    end
  end

  describe "#frontmatter" do
    it "includes the title, slug, and draft flag" do
      generator = BlogPostGenerator.new(title: "My Great Post")
      expected = <<~YAML
        ---
        page_title: My Great Post
        nav: my-great-post
        draft: true
        ---
      YAML
      expect(generator.frontmatter).to eq(expected)
    end
  end

  describe "#boilerplate" do
    it "includes the title in an h1 and the page content wrapper" do
      generator = BlogPostGenerator.new(title: "My Great Post")
      expected = <<~HTML

        <div class="container page-container">
          <h1>My Great Post</h1>

          <div class="page-content">
          </div>
        </div>
      HTML
      expect(generator.boilerplate).to eq(expected)
    end
  end
end
