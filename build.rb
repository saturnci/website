require "fileutils"

SOURCE_DIR = "src"
DIST_DIR = "dist"

FileUtils.rm_rf DIST_DIR

# go through the files in src
# for each one, compile it with rouge and write it to dist

Dir.glob("#{SOURCE_DIR}/**/*.html").each do |file|
  puts "compiling #{file}"
  File.open("#{DIST_DIR}/#{file.gsub(SOURCE_DIR, "")}", "w") do |f|
    f.write(File.read(file).gsub(/<pre><code>/, "<pre class='rouge'><code class='rouge'>"))
  end
end
