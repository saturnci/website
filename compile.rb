require_relative "documentation_file"

filename = ARGV[0]

documentation_file = DocumentationFile.new(filename, File.read(filename))
puts documentation_file.content
