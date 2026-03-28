require 'nokogiri'

class Excerpt
  MAX_LENGTH = 160

  def self.from_html(html)
    text = Nokogiri::HTML.fragment(html).text.gsub(/\s+/, ' ').strip
    if text.length > MAX_LENGTH
      text[0...MAX_LENGTH] + "..."
    else
      text
    end
  end
end
