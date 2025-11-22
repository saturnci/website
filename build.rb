#!/usr/bin/env ruby

begin
  require 'rouge'
rescue LoadError
  puts "Rouge gem not found. Install with: gem install rouge"
  exit 1
end

require_relative 'lib/site_source'
require_relative 'lib/site_build'

# Build the site
if __FILE__ == $0
  source = SiteSource.new('.')
  build = SiteBuild.new(source, 'public')
  build.execute
end