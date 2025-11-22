require_relative '../lib/site_build'
require_relative '../lib/site_source'
require 'tmpdir'
require 'fileutils'

RSpec.describe SiteBuild do
  it "generates a complete HTML page from source files" do
    Dir.mktmpdir do |tmpdir|
      # Set up test directory structure
      pages_dir = File.join(tmpdir, 'pages')
      layouts_dir = File.join(tmpdir, 'layouts')
      output_dir = File.join(tmpdir, 'public')

      FileUtils.mkdir_p(pages_dir)
      FileUtils.mkdir_p(layouts_dir)

      # Create test page with frontmatter
      File.write(File.join(pages_dir, 'test.html'), <<~HTML)
        ---
        page_title: Test Page
        ---
        <h1>Hello World</h1>
        <p>This is a test page.</p>
      HTML

      # Create minimal layout
      File.write(File.join(layouts_dir, 'default.html.erb'), <<~ERB)
        <html>
        <head><title><%= page_title %></title></head>
        <body><%= content %></body>
        </html>
      ERB

      # Build the site
      source = SiteSource.new(tmpdir)
      build = SiteBuild.new(source, output_dir)
      build.execute

      # Verify the output
      output_file = File.join(output_dir, 'test.html')
      expect(File.exist?(output_file)).to be true

      content = File.read(output_file)
      expect(content).to include('<title>Test Page</title>')
      expect(content).to include('<h1>Hello World</h1>')
      expect(content).to include('<p>This is a test page.</p>')
    end
  end
end