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

    context "when the page is a blog post" do
      it "sets og_description to an excerpt of the content" do
        blog_page = {
          filename: 'my-post',
          frontmatter: { 'page_title' => 'My Post' },
          content: '<h1>My Post</h1><p>This is a blog post about testing in Rails.</p>',
          path: 'src/blog/my-post.html'
        }
        layout = '<%= og_description %>'
        source = double('SiteSource', pages: [blog_page])
        build = SiteBuild.new(source, 'public')

        html = build.render_page(blog_page, layout, [blog_page])

        expect(html).to include("This is a blog post about testing in Rails.")
        expect(html).not_to include("My Post")
      end
    end

    context "when the page is not a blog post" do
      it "sets og_description to the generic site description" do
        regular_page = {
          filename: 'about',
          frontmatter: { 'page_title' => 'About' },
          content: '<p>About us.</p>',
          path: 'src/pages/about.html'
        }
        layout = '<%= og_description %>'
        source = double('SiteSource', pages: [regular_page])
        build = SiteBuild.new(source, 'public')

        html = build.render_page(regular_page, layout, [regular_page])

        expect(html).to include(SiteBuild::DEFAULT_OG_DESCRIPTION)
      end
    end
  end
end