# ogp.rb - add Open Graph Protocol <meta> tags to header
#
# Copyright (c) 2011 MATSUOKA Kohei <kmachu@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#

# @conf['ogp.facebook.app_id'] - your facebook application ID.
# @conf['ogp.facebook.admins'] - your facebook ID.

def ogp_description
	section_index = @cgi.params['p'][0]
	# section_index = "1"
	if @mode == 'day' and section_index
		diary = @diaries[@date.strftime('%Y%m%d')]
		sections = diary.instance_variable_get(:@sections)
		section = sections[section_index.to_i - 1].body_to_html
		@conf.shorten(apply_plugin(section, true), 200)
	else
		@conf.description
	end
end

add_header_proc do
	headers = {
		# TODO: og:urlへ対応
		'og:title' => title_tag.match(/>([^<]+)</).to_a[1],
		'og:site_name' => @conf.html_title,
		'og:description' => ogp_description,
		'og:image' => @conf.banner,
		'og:type' => (@mode == 'day') ? 'article' : 'blog',
		'og:author' => @conf.author_name,
		'fb:app_id' => @conf['ogp.facebook.app_id'],
		'fb:admins' => @conf['ogp.facebook.admins']
	}
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
