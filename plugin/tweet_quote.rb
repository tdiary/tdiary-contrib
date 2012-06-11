# -*- coding: utf-8 -*-
#
# tweet_quote.rb - tDiary plugin to quote tweet on twitter.com,
# formaly known as blackbird-pie.rb
#
# Copyright (C) 2010, hb <smallstyle@gmail.com>
#
# usage:
#    <%= tweet_quote "id|url" %>
#     or
#    <%= twitter_quote "id|url" %>
#     or
#    <%= blackbird_pie "id|url" %>
#     or
#    <%= bbp "id|url" %>
#

require 'pstore'
require 'open-uri'
require 'timeout'
require 'rexml/document'
require 'time'
require 'uri'

def twitter_statuses_show_api( tweet_id )
	url = "http://api.twitter.com/1/statuses/show/#{tweet_id}.xml"

	proxy = @conf['proxy']
	proxy = 'http://' + proxy if proxy

	timeout( 20 ) do
		open( url, :proxy => proxy ) {|f| f.read }
	end
end


def tweet_quote( src )
	if %r|http://twitter.com/(?:#!/)?[^/]{1,15}/status(?:es)?/([0-9]+)| =~ src.to_s.downcase
		src = $1
	end

	return unless /\A[0-9]+\z/ =~ src.to_s

	cache = "#{@cache_path}/blackbird.pstore"
	xml = nil

	db = PStore.new( cache )
	db.transaction do
		key = src
		db[key] ||= {}
		if db[key][:xml]
			xml = db[key][:xml]
		else
			begin
				xml = twitter_statuses_show_api( src )
			rescue OpenURI::HTTPError
				return %Q|<p class="bbpMessage">#$!</p>|
			end
			db[key][:xml] = xml
		end
	end

	doc = REXML::Document::new( REXML::Source.new( xml ) ).root

	tweet_id = doc.elements['//id'].text
	screen_name = doc.elements['//user/screen_name'].text
	name = doc.elements['//user/name'].text
	background_url = doc.elements['//user/profile_background_image_url'].text
	profile_background_color = '#' + doc.elements['//user/profile_background_color'].text
	avatar = doc.elements['//user/profile_image_url'].text
	source = doc.elements['//source'].text
	timestamp = Time.parse( doc.elements['//created_at'].text ).to_s
	content = doc.elements['//text'].text
	content.gsub!( URI.regexp( %w|http https| ) ){ %Q|<a href="#{$&}">#{$&}</a>| }
	content = content.split( /(<[^>]*>)/ ).map do |s|
		next s if s[/\A</]
		s.gsub!( /@(?>([a-zA-Z0-9_]{1,15}))(?![a-zA-Z0-9_])/ ){ %Q|<a href="http://twitter.com/#{$1}">#{$&}</a>| }
		s.gsub( /#([a-zA-Z0-9]{1,16})/ ){ %Q|<a href="http://twitter.com/search?q=%23#{$1}">#{$&}</a>| }
	end.join

	r = <<-HTML
	<!-- http://twitter.com/#{screen_name}/status/#{tweet_id} -->
	<div class="bbpBox" style=
	"background:url(#{background_url}) #{profile_background_color};padding:20px;">
	<p class="bbpTweet" style=
		"background:#fff;padding:10px 12px 10px 12px;margin:0;min-height:48px;color:#000;font-size:16px !important;line-height:22px;-moz-border-radius:5px;-webkit-border-radius:5px;">
		#{content} <span class="bbpTimestamp" style=
		"font-size:12px;display:block;"><a title="#{timestamp}" href=
		"http://twitter.com/#{screen_name}/status/#{tweet_id}">#{timestamp}</a> via #{source}
		</span> <span class="bbpMetadata" style=
		"display:block;width:100%;clear:both;margin-top:8px;padding-top:12px;height:40px;border-top:1px solid #fff;border-top:1px solid #e6e6e6;">
		<span class="bbpAuthor" style="line-height:19px;"><a href=
		"http://twitter.com/#{screen_name}"><img alt="#{name}" src=
		"#{avatar}" style=
		"float:left;margin:0 7px 0 0;width:38px;height:38px;"></a>
		<strong><a href=
		"http://twitter.com/#{screen_name}">#{screen_name}</a></strong><br>
		#{name}</span></span></p>
	</div>
	<!-- end of tweet -->
	HTML
end

alias :blackbird_pie :tweet_quote
alias :bbp :tweet_quote
alias :twitter_quote :tweet_quote
