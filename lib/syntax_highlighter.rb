module SyntaxHighlighter

  def highlight_code_blocks(content)
    content.gsub(/<pre><code class="language-(\w+)">(.*?)<\/code><\/pre>/m) do
      language = $1
      code = $2

      lexer = Rouge::Lexer.find(language)
      formatter = Rouge::Formatters::HTML.new(css_class: 'highlight')

      highlighted = formatter.format(lexer.lex(code))
      "<pre class=\"highlight\"><code>#{highlighted}</code></pre>"
    end
  end
end