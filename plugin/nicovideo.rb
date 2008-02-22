#
# nicovideo.rb - tdiary plugin for Nico Nico Video
#
# Copyright (C) TADA Tadashi <sho@spc.gr.jp>
# Distributed under GPL.
#
# usage: <%= nicovideo 'sm99999999' %>
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

def nicovideo_inline( elem )
	url = elem.to_a( 'watch_url' )[0].text
	thumb = elem.to_a( 'thumbnail_url' )[0].text
	title = elem.to_a( 'title' )[0].text
	desc = elem.to_a( 'description' )[0].text
	comment = elem.to_a( 'last_res_body' )[0].text
	length = elem.to_a( 'length' )[0].text
	view = elem.to_a( 'view_counter' )[0].text
	comment_num = elem.to_a( 'comment_num' )[0].text
	mylist = elem.to_a( 'mylist_counter' )[0].text

	if feed? then
		result = <<-HTML
			<table border="0" cellpadding="4" cellspacing="0" summary="#{title}"><tr valign="top">
			<td><a href="#{url}"><img alt="#{title}" src="#{thumb}" width="130" height="100" style="border:solid 1px #333;"></a></td>
			<td width="100%"><a href="#{url}"><strong>#{title}</strong></a> (#{length})<br>#{desc}</td>
			</tr></table>
		HTML
	else
		result = <<-HTML
			<table border="0" cellpadding="4" cellspacing="0" summary="#{title}" style="margin-left:0em;">
			<tr valign="top">
			<td style="font-size:70%;border-width:0px;">
			<div style="margin:4px 0px;"><a href="#{url}" target="_blank"><img alt="#{title}" src="#{thumb}" width="130" height="100" style="border:solid 1px #333;"></a></div>
			<p><strong>#{length}</strong><br>
			再生: <strong>#{view}</strong><br>
			コメント: <strong>#{comment_num}</strong><br>
			マイリスト:<strong>#{mylist}</strong></p>
			</td>
			<td width="100%" style="font-size:80%;border-width:0px;">
			<p><a href="#{url}" target="_blank" class="video"><strong>#{title}</strong></a><br>#{desc}</p>
			<div style="background:#FFF; border:solid 2px #CCC; padding:6px; margin-top:4px;">
			<p><strong>#{comment}</strong></p>
			</div>
			</td>
			</tr>
			</table>
		HTML
	end
	result.gsub( /^\t*/, '' )
end

def nicovideo_iframe( video_id )
	%Q|<iframe src="http://www.nicovideo.jp/thumb/#{video_id}" scrolling="no" style="border:solid 1px #CCC;" frameborder="0"><a href="http://www.nicovideo.jp/watch/#{video_id}">#{label || 'link for nicovideo'}</a></iframe>\n|
end

def nicovideo( video_id, label = nil )
	begin
		@conf.to_native( nicovideo_inline( nicovideo_call_api( video_id ).elements ), 'UTF-8' )
	rescue ::Errno::ENOENT
		"<strong>Sorry, #{video_id} was deleted.</strong>"
	rescue Timeout::Error
		nicovideo_iframe( video_id )
	end
end
