#
# twitter_badge.rb: twitter status plugin for tDiary
#
# Copyright (C) 2007 by Nishimoto Masaki <gaju@gaju.jp>
# Distributed under GPL.
#

require 'open-uri'
require 'timeout'
require 'rexml/document'

def twitter_badge( id, count )
	begin
		cache = "#{@cache_path}/twitter_badge.xml"
		xml = open( cache ) {|f| f.read }
		if Time::now > File::mtime( cache ) + 10*60 then
			File::delete( cache )  # clear cache 10 minutes later
		end
	rescue Errno::ENOENT
		begin
			xml = twitter_badge_call_api( id )
			open( cache, 'wb' ) {|f| f.write( xml ) }
		rescue Timeout::Error, StandardError
			return %Q|<div class="twitter-badge error">twitter_badge: #{$!}</div>|
		end
	end

	doc = REXML::Document::new( xml )
	if doc then
		html = '<div class="twitter-badge">'
		html << '<p class="twitter-badge-title">'
		html << %Q|<a href="http://twitter.com/#{id}">| << 'What am I doing...</a>'
		html << '</p>'
		html << '<ul class="twitter-badge-body">'
		i = 0
		doc.elements.each( 'statuses/status' ) do |status|
			created_at = Time.parse( status.elements.to_a( 'created_at' )[0].text )
			text = status.elements.to_a( 'text' )[0].text
			if /^\@(.*)?/.match( text ) == nil and i < count then
				html << '<li class="twitter-badge-status">'
				if Time.now > created_at + 60*60*23 then
					time = created_at.localtime.strftime( '%b %d %H:%M' )
				else
					time = created_at.localtime.strftime( '%H:%M' )
				end
				html << '<span class="twitter-badge-text">' << %Q|#{text}| << '</span> '
				html << '<span class="twitter-badge-time">(' << %Q|#{time}| << ')</span>'
				html << '</li>'
				i += 1
			end
		end
		html << '</ul></div>'
		@conf.to_native( html )
	else
		return '<div class="twitter-badge error">twitter_badge: Failed to open file</div>'
	end
end

def twitter_badge_call_api( id )
	request = "http://twitter.com/statuses/user_timeline/#{id}.xml"

	proxy = @conf['proxy']
	proxy = 'http://' + proxy if proxy
	timeout( 10 ) do
		open( request, :proxy => proxy ) {|f| f.read }
	end
end
