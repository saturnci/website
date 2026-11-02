require 'rouge'
require_relative '../lib/syntax_highlighter'

RSpec.describe SyntaxHighlighter do
  include SyntaxHighlighter

  it "does not double-escape HTML entities" do
    html = highlight_code_blocks('<pre><code class="language-ruby">"&lt;hr&gt;"</code></pre>')

    expect(html).not_to include('&amp;lt;')
  end
end
