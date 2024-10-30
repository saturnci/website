require_relative "./code_block"

class DocumentationFile
  attr_reader :content

  def initialize(path, content)
    @path = path
    @content = content
  end

  def code_blocks
    content.scan(/<pre class="language-(\w+)">(.*?)<\/pre>/m).map do |match|
      CodeBlock.new(match[0], match[1].strip)
    end
  end
end
