#!/usr/bin/env ruby

require 'rouge'
require_relative 'lib/site_source'
require_relative 'lib/site_build'

# Build the site
if __FILE__ == $0
  source = SiteSource.new('.')
  build = SiteBuild.new(source, 'public')
  build.execute
end
