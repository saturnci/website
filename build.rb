#!/usr/bin/env ruby

require 'rouge'
require_relative 'lib/site_source'
require_relative 'lib/site_build'

# Build the site
if __FILE__ == $0
  environment = ENV['SITE_ENV'] || 'production'
  source = SiteSource.new('src', environment: environment, root_path: '.')
  build = SiteBuild.new(source, 'public')
  build.execute
end
