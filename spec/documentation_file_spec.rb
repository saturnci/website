require_relative "../documentation_file"

RSpec.describe DocumentationFile do
  it "works" do
    content = <<~CONTENT
      Here is some Ruby:

      <pre class="language-ruby">
      puts "Hello, world!"
      </pre>
      Here is some Python:

      <pre class="language-python">
      print("Hello, world!")
      </pre>
    CONTENT

    documentation_file = DocumentationFile.new(
      "docs.html",
      content
    )

    expect(documentation_file.code_blocks[0].content)
      .to eq("puts \"Hello, world!\"")
  end
end
