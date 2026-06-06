require_relative '../lib/rss_feed'

RSpec.describe RssFeed do
  let(:post) do
    {
      filename: 'my-post',
      frontmatter: { 'page_title' => 'My Post', 'date' => '2026-05-01' },
      content: '<h1>My Post</h1><p>This is the body of my post.</p>',
      path: 'src/blog/my-post.html'
    }
  end

  def items(xml)
    Nokogiri::XML(xml).css('item')
  end

  describe "#to_xml" do
    it "includes a post's title" do
      xml = RssFeed.new([post], site_url: 'https://www.saturnci.com').to_xml

      expect(items(xml).first.css('title').text).to eq('My Post')
    end

    it "links each item to the post's URL on the site" do
      xml = RssFeed.new([post], site_url: 'https://www.saturnci.com').to_xml

      expect(items(xml).first.css('link').text).to eq('https://www.saturnci.com/my-post.html')
    end

    it "uses the post excerpt as the item description" do
      xml = RssFeed.new([post], site_url: 'https://www.saturnci.com').to_xml

      expect(items(xml).first.css('description').text).to eq('This is the body of my post.')
    end

    it "formats the publication date in RFC-822" do
      xml = RssFeed.new([post], site_url: 'https://www.saturnci.com').to_xml

      expect(items(xml).first.css('pubDate').text).to eq('Fri, 01 May 2026 00:00:00 -0000')
    end

    it "orders items newest first" do
      older = post.merge(frontmatter: { 'page_title' => 'Older', 'date' => '2026-01-01' })
      newer = post.merge(frontmatter: { 'page_title' => 'Newer', 'date' => '2026-12-01' })

      xml = RssFeed.new([older, newer], site_url: 'https://www.saturnci.com').to_xml

      expect(items(xml).map { |item| item.css('title').text }).to eq(['Newer', 'Older'])
    end

    it "describes the channel itself" do
      xml = RssFeed.new([post], site_url: 'https://www.saturnci.com').to_xml
      channel = Nokogiri::XML(xml).css('channel')

      expect(channel.css('> title').text).to eq('SaturnCI Blog')
      expect(channel.css('> link').text).to eq('https://www.saturnci.com/blog.html')
    end
  end
end
