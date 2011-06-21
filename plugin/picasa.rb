# show photo image on Picasa Web Album
#
# usage:
#   picasa( src[, title[, place]] )
#     - src: The url of the photo to show.
#     - title: title of photo. (optional)
#     - place: class name of img element. default is 'photo'.
#
#   picasa_left( src[, title] )
#
#   picasa_right( src[, title] )
#
# options configurable through settings:
#   @conf['picasa.user'] : picasa username
#   @conf['picasa.default_size'] : default image size
#
# Copyright (c) hb <http://www.smallstyle.com>
# Distributed under the GPL.
#

def picasa( src, alt = "photo", place = 'photo' )
	src.sub!( %r|/s\d+/|, "/s200/" ) if @conf.iphone?
	
	if @cgi.mobile_agent?
		body = %Q|<a href="#{src}">#{alt}</a>|
	else
		body = %Q|<img title="#{alt}" alt="#{alt}" src="#{src}" class="#{place} picasa">|
	end
	body
end

def picasa_left( src, alt = "photo" )
	picasa( src, alt, 'left' )
end

def picasa_right( src, alt = "photo" )
	picasa( src, alt, 'right' )
end

if /\A(form|edit|preview|showcomment)\z/ === @mode then
	enable_js( 'picasa.js' )
	add_js_setting( '$tDiary.plugin.picasa' )
	add_js_setting( '$tDiary.plugin.picasa.userId', %Q|'#{@conf['picasa.user']}'| )
	add_js_setting( '$tDiary.plugin.picasa.imgMax', %Q|'#{@conf[ 'picasa.default_size'] || 400}'| )
end

add_edit_proc do |date|
	unless @conf['picasa.user'] 
		'<p>[ERROR] picasa.rb: Picasa username is not specified.</p>'
	else
		<<-HTML
			<div id="plugin_picasa"></div>
		HTML
	end
end
