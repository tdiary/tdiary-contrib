#
# ustream.rb - insert some services of Ustream.tv
#
# Copyright (C) 2010, TADA Tadashi <t@tdtds.jp>.
# You can redistribute it and/or modify it under GPL2.
#

def ustream( id, type = :recorded )
	if type == :live then
		return ''
	end

	# insert recorded video
	if @conf.mobile_agent? or @conf.iphone? or feed? then
		return %Q|<a href="http://www.ustream.tv/recorded/#{id}">Link to Ustream ##{id}</a></p><p>|
	end

	return %Q|<object class="ustream" classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" width="480" height="386" id="utv787024" name="utv_n_101164"><param name="flashvars" value="loc=%2F&amp;autoplay=false&amp;vid=#{id}"><param name="allowfullscreen" value="true"><param name="allowscriptaccess" value="always"><param name="src" value="http://www.ustream.tv/flash/video/#{id}"><embed flashvars="loc=%2F&amp;autoplay=false&amp;vid=#{id}" width="480" height="386" allowfullscreen="true" allowscriptaccess="always" id="utv787024" name="utv_n_101164" src="http://www.ustream.tv/flash/video/#{id}" type="application/x-shockwave-flash"></object>|
end
