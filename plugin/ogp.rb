# ogp.rb - add Open Graph Protocol <meta> tags to header
#
# Copyright (c) 2011 MATSUOKA Kohei <kmachu@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#

# @conf['ogp.facebook.app_id'] - your facebook application ID.
# @conf['ogp.facebook.admins'] - your facebook ID.

add_header_proc do
	headers = {
		'og:title' => title_tag.match(/>([^<]+)</).to_a[1],
		'og:site_name' => @conf.html_title,
		'og:description' => @conf.description,
		'og:image' => @conf.banner,
		'og:type' => (@mode == 'day') ? 'article' : 'blog',
		'og:author' => @conf.author_name,
		'fb:app_id' => @conf['ogp.facebook.app_id'],
		'fb:admins' => @conf['ogp.facebook.admins']
	}
	# headers['og:type'] = (@mode == 'day') ? 'article' : 'blog'
	headers.select {|key, val|
		val && !val.empty?
	}.map {|key, val|
		%Q|<meta property="#{key}" content="#{CGI::escapeHTML(val)}">|
	}.join("\n")
end

add_conf_proc('Open Graph Protocol', 'Open Graph Protocol') do
	if @mode == 'saveconf'
		@conf['ogp.facebook.app_id'] = @cgi.params['ogp.facebook.app_id'][0]
		@conf['ogp.facebook.admins'] = @cgi.params['ogp.facebook.admins'][0]
	end

	<<-HTML
	<h3>Facebook Application ID</h3>
	<p><input name="ogp.facebook.app_id" value="#{h(@conf['ogp.facebook.app_id'])}"></p>

	<h3>Facebook User ID</h3>
	<p><input name="ogp.facebook.admins" value="#{h(@conf['ogp.facebook.admins'])}"></p>
	HTML
end
