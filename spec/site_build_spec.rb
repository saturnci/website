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

    it "renders a page with layout and frontmatter" do
      source = double('SiteSource', pages: all_pages)
      build = SiteBuild.new(source, 'public')

      html = build.render_page(page, layout_template, all_pages)

      expect(html).to include('<title>Test Page</title>')
      expect(html).to include('<h1>Hello World</h1>')
      expect(html).to include('<p>This is a test page.</p>')
    end
  end
end