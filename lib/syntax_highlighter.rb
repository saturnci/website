module SyntaxHighlighter

  def highlight_code_blocks(content)
    content.gsub(/<pre(?: data-filename="([^"]*)")?><code class="language-(\w+)">(.*?)<\/code><\/pre>/m) do
      filename = $1
      language = $2
      code = $3

      lexer = Rouge::Lexer.find(language)
      formatter = Rouge::Formatters::HTML.new(css_class: 'highlight')

      highlighted = formatter.format(lexer.lex(code))

      if filename
        "<div class=\"code-block\"><div class=\"code-filename\">#{filename}</div><pre class=\"highlight\"><code>#{highlighted}</code></pre></div>"
      else
        "<pre class=\"highlight\"><code>#{highlighted}</code></pre>"
      end
    end
  end
end