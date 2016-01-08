#
# recemt_tweet.rb: Twitter status plugin for tDiary
#
# Copyright (C) 2007 by Nishimoto Masaki <gaju@gaju.jp>
# Distributed under GPL.
#

require 'open-uri'
require 'timeout'
require 'rexml/document'

def recent_tweet( id, count )
	begin
		cache = "#{@cache_path}/recent_tweet.xml"
		xml = open( cache ) {|f| f.read }
		if Time::now > File::mtime( cache ) + 10*60 then
			File::delete( cache )  # clear cache 10 minutes later
		end
	rescue Errno::ENOENT
		begin
			xml = recent_tweet_call_api( id )
			open( cache, 'wb' ) {|f| f.write( xml ) }
		rescue Timeout::Error, StandardError
			return %Q|<div class="recent_tweet error">recent_tweet: #{$!}</div>|
		end
	end

	begin
		doc = REXML::Document::new( xml )
		if doc then
			html = '<div class="recent-tweet">'
			html << '<p class="recent-tweet-title">'
			html << '<a href="http://twitter.com/' << id << '">What am I doing...</a>'
			html << '</p>'
			html << '<ul class="recent-tweet-body">'
			i = 0
			doc.elements.each( 'statuses/status' ) do |status|
				created_at = Time.parse( status.elements.to_a( 'created_at' )[0].text )
				text = status.elements.to_a( 'text' )[0].text
				if /^@/.match( text ) == nil and i < count then
					html << '<li class="recent-tweet-status">'
					if Time.now > created_at + 60*60*23 then
						time = created_at.localtime.strftime( '%b %d %H:%M' )
					else
						time = created_at.localtime.strftime( '%H:%M' )
					end
					html << '<span class="recent-tweet-text">' << %Q|#{text}| << '</span> '
					html << '<span class="recent-tweet-time">(' << %Q|#{time}| << ')</span>'
					html << '</li>'
					i += 1
				end
			end
			html << '</ul></div>'
			@conf.to_native( html )
		else
			return '<div class="recent-tweet error">recent_tweet: Failed to open file</div>'
		end
	rescue REXML::ParseException
		return '<div class="recent-tweet error">recent_tweet: Failed to parse XML</div>'
	end
end

def recent_tweet_call_api( id )
	request = "http://twitter.com/statuses/user_timeline/#{id}.xml"

	proxy = @conf['proxy']
	proxy = 'http://' + proxy if proxy
	Timeout.timeout( 10 ) do
		open( request, :proxy => proxy ) {|f| f.read }
	end
end
