#
# apple-webclip.rb - Add icon information for Apple WebClip.
#
# Copyright (C) 2008, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL.
#

add_header_proc do
	if @conf['apple-webclip.url'] and @conf['apple-webclip.url'].size > 0
		%Q|	<link rel="apple-touch-icon" href="#{h @conf['apple-webclip.url']}"/>\n|
	else
		''
	end
end

add_conf_proc( 'apple-webclip', 'Apple WebClip' ) do
	if @mode == 'saveconf' then
      @conf['apple-webclip.url'] = @cgi.params['apple-webclip.url'][0]
	end

	<<-HTML
   <h3 class="subtitle">Icon URL</h3>
   <p><input name="apple-webclip.url" value="#{h @conf['apple-webclip.url']}" size="70"></p>
	<p>Create and cpecify PNG file 60x60 pixels.</p>
   HTML
end
