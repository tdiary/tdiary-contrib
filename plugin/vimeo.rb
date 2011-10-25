#
# vimeo.rb - insert some services of vimeo.com
#
# Copyright (C) 2011, Kiwamu Okabe <kiwamu@debian.or.jp>.
# You can redistribute it and/or modify it under GPL2.
#

def vimeo( id )
	if @conf.mobile_agent? or @conf.iphone? or feed? then
		return %Q|<a href="http://vimeo.com/#{id}">Link to vimeo ##{id}</a></p><p>|
	end

	%Q|<iframe src="http://player.vimeo.com/video/#{id}?title=0&amp;byline=0&amp;portrait=0" width="400" height="300" frameborder="0" webkitAllowFullScreen allowFullScreen></iframe>|
end
