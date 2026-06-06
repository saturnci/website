require 'nokogiri'
require 'date'
require 'time'
require_relative 'excerpt'

class RssFeed
  def initialize(posts, site_url:)
    @posts = posts
    @site_url = site_url
  end

  def to_xml
    Nokogiri::XML::Builder.new do |xml|
      xml.rss(version: '2.0') do
        xml.channel do
          xml.title 'SaturnCI Blog'
          xml.link "#{@site_url}/blog.html"
          xml.description 'The latest posts from the SaturnCI blog.'

          sorted_posts.each do |post|
            xml.item do
              xml.title post[:frontmatter]['page_title']
              xml.link "#{@site_url}/#{post[:filename]}.html"
              xml.description Excerpt.from_html(post[:content])
              xml.pubDate pub_date(post)
            end
          end
        end
      end
    end.to_xml
  end

  private

  def sorted_posts
    @posts.sort_by { |post| post[:frontmatter]['date'] }.reverse
  end

  def pub_date(post)
    Date.parse(post[:frontmatter]['date']).then { |d| Time.utc(d.year, d.month, d.day) }.rfc822
  end
end
