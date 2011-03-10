# -*- coding: utf-8 -*-
# Copyright (C) 2011, KADO Masanori <kdmsnr@gmail.com>
# You can redistribute it and/or modify it under GPL.

add_header_proc do
<<-HTML
<meta property="fb:admins" content="#{h @conf['facebook_comments.YOUR_FACEBOOK_USER_ID']}"/>
<meta property="fb:app_id" content="#{h @conf['facebook_comments.YOUR_APPLICATION_ID']}">
HTML
end

def facebook_comments(href = '')
<<-HTML
<div id="fb-root"></div><script src="http://connect.facebook.net/ja_JP/all.js#appId=#{h @conf['facebook_comments.YOUR_APPLICATION_ID']}&amp;xfbml=1"></script><fb:comments href="#{h href}" num_posts="#{h @conf['facebook_comments.num_posts']}" width="#{h @conf['facebook_comments.width']}"></fb:comments>
HTML
end

add_body_leave_proc do |date|
	if @mode == 'day'
		href = @conf.base_url + anchor( @date.strftime('%Y%m%d') )
		facebook_comments(href)
	end
end

add_conf_proc( 'Facebook Comments', 'Facebook Comments', 'etc' ) do
	if @mode == 'saveconf' then
		@conf['facebook_comments.YOUR_FACEBOOK_USER_ID'] =
			@cgi.params['facebook_comments.YOUR_FACEBOOK_USER_ID'][0]
		@conf['facebook_comments.YOUR_APPLICATION_ID'] =
			@cgi.params['facebook_comments.YOUR_APPLICATION_ID'][0]
		@conf['facebook_comments.num_posts'] =
			@cgi.params['facebook_comments.num_posts'][0]
		@conf['facebook_comments.width'] =
			@cgi.params['facebook_comments.width'][0]
	end

	<<-HTML
   <h3>YOUR_FACEBOOK_USER_ID</h3>
   <p><input size="88" name="facebook_comments.YOUR_FACEBOOK_USER_ID" value="#{h @conf['facebook_comments.YOUR_FACEBOOK_USER_ID']}"></p>

   <h3>YOUR_APPLICATION_ID</h3>
   <p><input size="88" name="facebook_comments.YOUR_APPLICATION_ID" value="#{h @conf['facebook_comments.YOUR_APPLICATION_ID']}"></p>

   <h3>num posts</h3>
   <p><input size="20" name="facebook_comments.num_posts" value="#{h @conf['facebook_comments.num_posts']}"></p>

   <h3>width</h3>
   <p><input size="20" name="facebook_comments.width" value="#{h @conf['facebook_comments.width']}"></p>
HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3

