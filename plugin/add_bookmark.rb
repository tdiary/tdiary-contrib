# add_bookmark.rb $Revision 1.3 $
#
# Copyright (c) 2005 SHIBATA Hiroshi <h-sbt@nifty.com>
# You can redistribute it and/or modify it under GPL2.

def bookmark_init
	@conf['add.bookmark.delicious'] ||= ""
	@conf['add.bookmark.hatena'] ||= ""
	@conf['add.bookmark.livedoor'] ||= ""
	@conf['add.bookmark.buzzurl'] ||= ""
end

add_subtitle_proc do |date, index, subtitle|
	bookmark_init
	
	if @conf.mobile_agent? then
		caption = %Q|#{subtitle}|
	else
		caption = %Q|#{subtitle} |

		section_url = @conf.base_url + anchor(date.strftime('%Y%m%d')) + '#p' + ('%02d' % index)
		
		if @conf['add.bookmark.delicious'] == "t" then
			caption += %Q|<a href="http://del.icio.us/post/v4?url=#{h(section_url)}">|
			caption += %Q|<img src="http://images.del.icio.us/static/img/delicious.small.gif" width="10" height="10" style="border: none;vertical-align: middle;" alt="#{@caption_delicious}" title="#{@caption_delicious}" />|
			caption += %Q|</a> |
		end

		if @conf['add.bookmark.hatena'] == "t" then
			caption += %Q|<a href="http://b.hatena.ne.jp/append?#{h(section_url)}">|
			caption += %Q|<img src="http://b.hatena.ne.jp/images/append.gif" width="16" height="12" style="border: none;vertical-align: middle;" alt="#{@caption_hatena}" title="#{@caption_hatena}" />|
			caption += %Q|</a> |
		end
			
		if @conf['add.bookmark.livedoor'] == "t" then
			caption += %Q|<a href="http://clip.livedoor.com/redirect?link=#{h(section_url)}" class="ldclip-redirect">|
			caption += %Q|<img src="http://parts.blog.livedoor.jp/img/cmn/clip_16_16_w.gif" width="16" height="16" style="border: none;vertical-align: middle;" alt="#{@caption_livedoor}" title="#{@caption_livedoor}" />|
			caption += %Q|</a> |
		end

		if @conf['add.bookmark.buzzurl'] == "t" then
			caption += %Q|<a href="http://buzzurl.jp/entry/#{h(section_url)}">|
			caption += %Q|<img src="http://buzzurl.jp/static/image/api/icon/add_icon_mini_10.gif" width="16" height="12" style="border: none;vertical-align: middle;" title="#{@caption_buzzurl}" alt="#{@caption_buzzurl}" class="icon" />|
			caption += %Q|</a> |
		end
	end
	
	<<-HTML
	#{caption}
	HTML
end

add_conf_proc( 'add_bookmark', @add_bookmark_label ) do
	add_bookmark_conf_proc
end

def add_bookmark_conf_proc
	bookmark_init
	saveconf_add_bookmark

	bookmark_categories = [
	'add.bookmark.delicious',
	'add.bookmark.hatena',
	'add.bookmark.livedoor',
	'add.bookmark.buzzurl'
	]

	r = ''
	r << %Q|<h3 class="subtitle">#{@add_bookmark_label}</h3><p>#{@add_bookmark_desc}</p><ul>|

	bookmark_categories.each_with_index do |idx,view|
		checked = "t" == @conf[idx] ? ' checked' : ''
		label = @bookmark_label[view]
		r << %Q|<li><label for="#{idx}"><input id=#{idx} name=#{idx} type="checkbox" value="t"#{checked}>#{label}</label></li>|
	end
	r << %Q|</ul>|
end

if @mode == 'saveconf'
	def saveconf_add_bookmark
		@conf['add.bookmark.delicious'] = @cgi.params['add.bookmark.delicious'][0]
		@conf['add.bookmark.hatena'] = @cgi.params['add.bookmark.hatena'][0]
		@conf['add.bookmark.livedoor'] = @cgi.params['add.bookmark.livedoor'][0]
		@conf['add.bookmark.buzzurl'] = @cgi.params['add.bookmark.buzzurl'][0]
	end
end
