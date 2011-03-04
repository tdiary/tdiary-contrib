# -*- coding: utf-8 -*-
# Copyright (C) 2011, KADO Masanori <kdmsnr@gmail.com>
# You can redistribute it and/or modify it under GPL.

add_header_proc do
<<-HTML
<meta property="fb:admins" content="#{h @conf['facebook_comments.YOUR_FACEBOOK_USER_ID']}"/>
<meta property="fb:app_id" content="#{h @conf['facebook_comments.YOUR_APPLICATION_ID']}">
HTML
end

add_body_leave_proc do
	@conf['facebook_comments.PLUGIN_CODE']
end

add_conf_proc( 'Facebook Comments', 'Facebook Comments', 'etc' ) do
	if @mode == 'saveconf' then
		@conf['facebook_comments.YOUR_FACEBOOK_USER_ID'] =
			@cgi.params['facebook_comments.YOUR_FACEBOOK_USER_ID'][0]
		@conf['facebook_comments.YOUR_APPLICATION_ID'] =
			@cgi.params['facebook_comments.YOUR_APPLICATION_ID'][0]
		@conf['facebook_comments.PLUGIN_CODE'] =
			@cgi.params['facebook_comments.PLUGIN_CODE'][0]
	end

	<<-HTML
   <h3>YOUR_FACEBOOK_USER_ID</h3>
   <p><input size="88" name="facebook_comments.YOUR_FACEBOOK_USER_ID" value="#{h @conf['facebook_comments.YOUR_FACEBOOK_USER_ID']}"></p>

   <h3>YOUR_APPLICATION_ID</h3>
   <p><input size="88" name="facebook_comments.YOUR_APPLICATION_ID" value="#{h @conf['facebook_comments.YOUR_APPLICATION_ID']}"></p>

   <h3>PLUGIN_CODE</h3>
   <p><textarea style="width:60%;height:100px;" name="facebook_comments.PLUGIN_CODE">#{h @conf['facebook_comments.PLUGIN_CODE']}</textarea></p>
HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3

