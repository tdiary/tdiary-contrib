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

	# flashvars+="locale=(ja_JP|en_US)"
	utv_id = "utv#{rand(1000000)}"
	utv_name = "utv_n_#{rand(1000000)}"
	%Q|<object class="ustream" classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" width="480" height="386" id="#{utv_id}" name="#{utv_name}"><param name="flashvars" value="autoplay=false"><param name="allowfullscreen" value="true"><param name="allowscriptaccess" value="always"><param name="src" value="http://www.ustream.tv/flash/video/#{id}"><embed flashvars="autoplay=false" width="480" height="386" allowfullscreen="true" allowscriptaccess="always" id="#{utv_id}" name="#{utv_name}" src="http://www.ustream.tv/flash/video/#{id}" type="application/x-shockwave-flash"></embed></object>|
end
