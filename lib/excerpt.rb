class Excerpt
  def self.from_html(html)
    text = html.gsub(/<[^>]+>/, ' ').gsub(/\s+/, ' ').strip
    if text.length > 160
      text[0...160] + "..."
    else
      text
    end
  end
end
