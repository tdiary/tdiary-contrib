#
# apple_webclip.rb - Add icon information for Apple WebClip.
#
# Copyright (C) 2008, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL.
#

add_header_proc do
	if @conf['apple_webclip.url'] and @conf['apple_webclip.url'].size > 0
		%Q|	<link rel="apple-touch-icon" href="#{h @conf['apple_webclip.url']}"/>\n|
	else
		''
	end
end

add_conf_proc( 'apple_webclip', 'Apple WebClip' ) do
	if @mode == 'saveconf' then
      @conf['apple_webclip.url'] = @cgi.params['apple_webclip.url'][0]
	end

	<<-HTML
   <h3 class="subtitle">Icon URL</h3>
   <p><input name="apple_webclip.url" value="#{h @conf['apple_webclip.url']}" size="70"></p>
	<p>Create and cpecify PNG file 60x60 pixels.</p>
   HTML
end
