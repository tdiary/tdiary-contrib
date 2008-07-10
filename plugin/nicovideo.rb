#
# nicovideo.rb - tdiary plugin for Nico Nico Video
#
# Copyright (C) TADA Tadashi <sho@spc.gr.jp>
# Distributed under GPL.
#
# usage:
#    Link to the movie and show thumbnail , description...:
#    <%= nicovideo 'sm99999999' %>
#
#    Link to the movie with original label:
#    <%= nicovideo 'sm99999999', 'movie title' %>
#
#    Link to the movie with original label and link:
#    <%= nicovideo 'sm99999999', 'movie title', 'http://example.com/video' %>
#
#    Show Inline player:
#    <%= nicovideo_player 'sm99999999' %>
#
#    Show Inline player with size:
#    <%= nicovideo_player 'sm99999999', [400,300] %>
#
require 'open-uri'
require 'timeout'
require 'rexml/document'

def nicovideo_call_api( video_id )
	uri = "http://www.nicovideo.jp/api/getthumbinfo/#{video_id}"
	proxy = @conf['proxy']
	proxy = 'http://' + proxy if proxy
	xml = timeout( feed? ? 10 : 2 ) { open( uri, :proxy => proxy ) {|f| f.read } }
	doc = REXML::Document::new( xml ).root
	res = doc.elements.to_a( '/nicovideo_thumb_response' )[0]
	if res.attributes['status'] == 'ok' then
		res.elements.to_a( 'thumb' )[0]
	else
		raise ::Errno::ENOENT::new
	end
end

def nicovideo_inline( elem, label = nil, link = nil )
	i = {}
	i[:url] = link || elem.to_a( 'watch_url' )[0].text
	i[:thumb] = elem.to_a( 'thumbnail_url' )[0].text
	i[:title] = label || elem.to_a( 'title' )[0].text
	i[:desc] = elem.to_a( 'description' )[0].text
	i[:comment] = @conf.mobile_agent? ? '' : elem.to_a( 'last_res_body' )[0].text
	i[:length] = elem.to_a( 'length' )[0].text
	i[:view] = elem.to_a( 'view_counter' )[0].text
	i[:comment_num] = elem.to_a( 'comment_num' )[0].text
	i[:mylist] = elem.to_a( 'mylist_counter' )[0].text

	if feed? then
		result = nicovideo_feed( i )
	else
		result = nicovideo_html( i )
	end
	result.gsub( /^\t+/, '' )
end

def nicovideo_iframe( video_id )
	%Q|<iframe src="http://www.nicovideo.jp/thumb/#{video_id}" scrolling="no" style="border:solid 1px #CCC;" frameborder="0"><a href="http://www.nicovideo.jp/watch/#{video_id}">#{label || 'link for nicovideo'}</a></iframe>\n|
end

def nicovideo( video_id, label = nil, link = nil )
	begin
		@conf.to_native( nicovideo_inline( nicovideo_call_api( video_id ).elements, label, link ), 'UTF-8' )
	rescue ::Errno::ENOENT
		"<strong>Sorry, #{video_id} was deleted.</strong>"
	rescue Timeout::Error, OpenURI::HTTPError, SecurityError
		nicovideo_iframe( video_id )
	end
end

def nicovideo_player( video_id, size = nil )
	if feed? or @conf.mobile_agent? then
		nicovideo( video_id )
	else
		s = ''
		if size then
			s = "?w=#{h size[0]}&h=#{h size[1]}"
		end
		%Q|<script type="text/javascript" src="#{nicovideo_player_path}/thumb_watch/#{video_id}#{s}"></script>|
	end
end
