require_relative '../lib/site_build'
require_relative '../lib/site_source'

RSpec.describe SiteBuild do
  describe "#render_page" do
    let(:layout_template) do
      <<~ERB
        <html>
        <head><title><%= page_title %></title></head>
        <body><%= content %></body>
        </html>
      ERB
    end

    let(:page) do
      {
        filename: 'test',
        frontmatter: { 'page_title' => 'Test Page' },
        content: "<h1>Hello World</h1>\n<p>This is a test page.</p>",
        path: 'test.html'
      }
    end

    let(:all_pages) { [page] }

    it "injects frontmatter values into the layout template" do
      source = double('SiteSource', pages: all_pages)
      build = SiteBuild.new(source, 'public')

      html = build.render_page(page, layout_template, all_pages)

      expect(html).to include('<title>Test Page</title>')
    end

    context "when og_description is provided" do
      it "uses the provided og_description" do
        test_page = {
          filename: 'my-post',
          frontmatter: { 'page_title' => 'My Post' },
          content: '<p>This is a blog post about testing in Rails.</p>',
          path: 'src/blog/my-post.html'
        }
        layout = '<%= og_description %>'
        source = double('SiteSource', pages: [test_page])
        build = SiteBuild.new(source, 'public')

        html = build.render_page(test_page, layout, [test_page], og_description: "Custom description")

        expect(html).to include("Custom description")
      end
    end

    context "when og_description is not provided" do
      it "uses the default site description" do
        test_page = {
          filename: 'about',
          frontmatter: { 'page_title' => 'About' },
          content: '<p>About us.</p>',
          path: 'src/pages/about.html'
        }
        layout = '<%= og_description %>'
        source = double('SiteSource', pages: [test_page])
        build = SiteBuild.new(source, 'public')

        html = build.render_page(test_page, layout, [test_page])

        expect(html).to include(SiteBuild::DEFAULT_OG_DESCRIPTION)
      end
    end
  end

  describe "#decorate_blog_post_content" do
    it "appends an author blurb" do
      source = double('SiteSource', pages: [], path: 'src')
      build = SiteBuild.new(source, 'public')

      content = "<h1>Test Post</h1>\n  <div class=\"page-content\">\n    <p>Some content.</p>\n  </div>\n</div>"
      result = build.decorate_blog_post_content(content)

      expect(result).to include('class="author-blurb"')
    end
  end
end