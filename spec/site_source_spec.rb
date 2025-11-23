require_relative '../lib/site_source'

RSpec.describe SiteSource do
  it "can be instantiated" do
    source = SiteSource.new('.')
    expect(source).to be_a(SiteSource)
  end

  describe "#filter_pages" do
    let(:published_page) do
      {
        filename: 'published',
        frontmatter: { 'title' => 'Published Page' },
        content: '<p>Published content</p>',
        path: 'published.html'
      }
    end

    let(:draft_page) do
      {
        filename: 'draft',
        frontmatter: { 'title' => 'Draft Page', 'draft' => true },
        content: '<p>Draft content</p>',
        path: 'draft.html'
      }
    end

    let(:all_pages) { [published_page, draft_page] }

    it "excludes draft pages in production mode" do
      source = SiteSource.new('.', environment: 'production')
      filtered = source.filter_pages(all_pages)

      expect(filtered.length).to eq(1)
      expect(filtered.first[:filename]).to eq('published')
    end

    it "includes draft pages in development mode" do
      source = SiteSource.new('.', environment: 'development')
      filtered = source.filter_pages(all_pages)

      expect(filtered.length).to eq(2)
      filenames = filtered.map { |p| p[:filename] }.sort
      expect(filenames).to eq(['draft', 'published'])
    end
  end
end