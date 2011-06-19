# socialbutton.rb
#
# Copyright (c) 2011 MATSUOKA Kohei <kmachu@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#

# enable social button names
@conf['socialbutton.enables'] ||= 'twitter,hatena,facebook_like'
# screen name of the user to attribute the tweet to 
@conf['socialbutton.twitter.via'] ||= ''

def socialbutton_js_settings
	enable_js('jquery.socialbutton.js')
	enable_js('socialbutton.js')
	add_js_setting('$tDiary.plugin.socialbutton')
	# convert array to json
	add_js_setting('$tDiary.plugin.socialbutton.enables', 
						%Q|["#{@conf['socialbutton.enables'].split(',').join('", "')}"]|)

	if @conf['socialbutton.twitter.via'] != ''
		options = "{ twitter: { via: '#{@conf['socialbutton.twitter.via']}' } }"
	else
		options = "{}"
	end
	add_js_setting('$tDiary.plugin.socialbutton.options', options)
end

socialbutton_footer = Proc.new { %Q|<div class="socialbuttons"></div>| }
if blogkit?
	add_body_leave_proc(socialbutton_footer)
else
	add_section_leave_proc(socialbutton_footer)
end

add_conf_proc('socialbutton', @socialbutton_label_conf) do
	@conf['socialbutton.enables'] ||= []
	if @mode == 'saveconf'
		@conf['socialbutton.enables'] = @cgi.params['socialbutton.enables'].join(",")
		@conf['socialbutton.twitter.via'] = @cgi.params['socialbutton.twitter.via'][0]
	end

	result = <<-HTML
		<h3>#{@socialbutton_label_enables}</h3>
		<ul>
	HTML
	['twitter', 'hatena', 'evernote', 'facebook_like'].each do |service|
		checked = @conf['socialbutton.enables'].index(service) ? 'checked' : ''
		id = "socialbutton.enables.#{service}"
		result << %Q|<li><input id="#{id}" name="socialbutton.enables" type="checkbox" value="#{service}" #{checked}>|
		result << %Q|<label for="#{id}">#{service}</label></li>|
	end
	result << <<-HTML
		</ul>
		<h3>#{@socialbutton_label_twitter_via}</h3>
		<p><input name="socialbutton.twitter.via" value="#{h(@conf['socialbutton.twitter.via'])}"></p>
	HTML
end

# load javascript
socialbutton_js_settings()
