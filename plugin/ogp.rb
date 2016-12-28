# ogp.rb - add Open Graph Protocol <meta> tags to header
#
# Copyright (c) 2011 MATSUOKA Kohei <kmachu@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#

# @conf['ogp.facebook.app_id'] - your facebook application ID.
# @conf['ogp.facebook.admins'] - your facebook ID.

def ogp_description(html)
	@conf.shorten(remove_tag(html), 200)
end

def ogp_image(html)
	images = html.scan(/<img.*?src="(.*?)"/)
	if !images.empty?
		images.first[0]
	else
		@conf.banner
	end
end

add_header_proc do
	headers = {
		'og:title' => title_tag.match(/>([^<]+)</).to_a[1],
		'og:site_name' => @conf.html_title,
		'og:author' => @conf.author_name,
		'fb:app_id' => @conf['ogp.facebook.app_id'],
		'fb:admins' => @conf['ogp.facebook.admins']
	}

	if @mode == 'day'
		diary = @diaries[@date.strftime('%Y%m%d')]
		if diary
			sections = diary.instance_variable_get(:@sections)
			section_index = @cgi.params['p'][0] || sections.size
			section = sections[section_index.to_i - 1].body_to_html
			section_html = apply_plugin(section)

			headers['og:description'] = ogp_description(section_html)
			headers['og:image'] = ogp_image(section_html)
			headers['og:type'] = 'article'
		end
	else
		headers['og:description'] = @conf.description
		headers['og:image'] = @conf.banner
		headers['og:type'] = 'website'
	end

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
