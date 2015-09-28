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
	%Q|<img title="#{alt}" alt="#{alt}" src="#{src}" class="#{place} picasa">|
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
			<h3 class="plugin_picasa"><span>Picasa Web Album</span></h3>
			<div id="plugin_picasa"></div>
		HTML
	end
end

add_conf_proc( 'picasa', 'Picasa' ) do
	if @mode == 'saveconf'
		@conf['picasa.user'], = @cgi.params['picasa.user']
		@conf['picasa.default_size'] = @cgi.params['picasa.default_size'][0].to_i
		@conf['picasa.default_size'] = 400 if @conf['picasa.default_size'] == 0
	end

	<<-HTML
	<h3 class="subtitle">Picasa user name</h3>
	<p><input name="picasa.user" value="#{h @conf['picasa.user']}"></p>

	<h3 class="subtitle">default size</h3>
	<p><input name="picasa.default_size" value="#{h @conf['picasa.default_size']}"></p>
	HTML
end
