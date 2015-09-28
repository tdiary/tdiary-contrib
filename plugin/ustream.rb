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
	if feed? then
		return %Q|<a href="http://www.ustream.tv/recorded/#{id}">Link to Ustream ##{id}</a></p><p>|
	end

	%Q|<iframe class="ustream" width="480" height="302" src="http://www.ustream.tv/embed/recorded/#{id}?v=3&amp;wmode=direct" scrolling="no" frameborder="0" style="border: 0px none transparent;"></iframe>|
end
