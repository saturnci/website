require 'nokogiri'

class Excerpt
  MAX_LENGTH = 160

  def self.from_html(html)
    doc = Nokogiri::HTML.fragment(html)
    doc.css('h1, h2, h3').remove
    text = doc.text.gsub(/\s+/, ' ').strip
    if text.length > MAX_LENGTH
      text[0...MAX_LENGTH] + "..."
    else
      text
    end
  end
end
