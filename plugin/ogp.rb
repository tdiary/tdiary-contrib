# ogp.rb - add Open Graph Protocol <meta> tags to header
#
# Copyright (c) 2011 MATSUOKA Kohei <kmachu@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#

# @conf['ogp.facebook.app_id'] - your facebook application ID.
# @conf['ogp.facebook.admins'] - your facebook ID.
# @conf['ogp.fediverse.creator'] - your fediverse ID.

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

if defined? :ogp_tag && !defined? :ogp_tag_org
	alias :ogp_tag_org :ogp_tag
end

def ogp_tag
	ogp = ogp_tag_org || ''
	headers = {
		'fb:app_id' => @conf['ogp.facebook.app_id'],
		'fb:admins' => @conf['ogp.facebook.admins'],
		'fediverse:creator' => @conf['ogp.fediverse.creator']
	}

	if @mode == 'day'
		# remove original og:image generated at 00default.rb
		ogp.gsub!(/<meta property="og:image"[^>]+>\n/, '')

		diary = @diaries[@date.strftime('%Y%m%d')]
		if diary
			sections = diary.instance_variable_get(:@sections)
			section_index = @cgi.params['p'][0] || sections.size
            begin
				section = sections[section_index.to_i - 1].body_to_html
				@image_date = @date.strftime("%Y%m%d") # hack for image plugin
				section_html = apply_plugin(section)

				headers['og:description'] = ogp_description(section_html)
				headers['og:image'] = ogp_image(section_html)
            rescue
            end
		end
	end

	ogp + "\n" + headers.select {|key, val|
		val && !val.empty?
	}.map {|key, val|
		%Q|<meta property="#{key}" content="#{CGI::escapeHTML(val)}">|
	}.join("\n")
end

add_conf_proc('Open Graph Protocol', 'Open Graph Protocol') do
	if @mode == 'saveconf'
		%w(
			ogp.facebook.app_id
			ogp.facebook.admins
			ogp.fediverse.creator
		).each do |name|
			@conf[name] = @cgi.params[name][0]
		end
	end

	<<-HTML
	<h3>Facebook Application ID</h3>
	<p><input name="ogp.facebook.app_id" value="#{h(@conf['ogp.facebook.app_id'])}"></p>

	<h3>Facebook User ID</h3>
	<p><input name="ogp.facebook.admins" value="#{h(@conf['ogp.facebook.admins'])}"></p>

	<h3>Fediverse ID</h3>
	<p><input name="ogp.fediverse.creator" value="#{h(@conf['ogp.fediverse.creator'])}"></p>
	HTML
end
