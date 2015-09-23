#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.xpath('//h2[span[@id="Results"]]/following-sibling::table[1]/tr[td]').each do |tr|
    tds = tr.css('td')
    next unless tds[2] && tds[2].text.to_s.include?('Elected')
    data = { 
      name: tds[0].text.tidy,
      party: "Non-Partisan",
      party_id: "IND",
      term: 2013,
      source: url,
    }
    puts data
    ScraperWiki.save_sqlite([:name, :term], data)
  end
end

scrape_list('https://en.wikipedia.org/wiki/Saint_Helena_general_election,_2013')
