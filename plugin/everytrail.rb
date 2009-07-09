#
# everytrail.rb: plugin embedding trip map on everytrail.com.
#
# Copyright (C) 2008 TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#

def everytrail( trip_id, label = nil, size = [400,300] )
	size.collect! {|i| i.to_i }
	size[0] = 400 if size[0] == 0
	size[0] = 300 if @conf.iphone?
	size[1] = 300 if size[1] == 0
	l = label ? %Q|<a href="http://www.everytrail.com/view_trip.php?trip_id=#{h trip_id}">#{h label}</a>| : ''
	%Q|<iframe src="http://www.everytrail.com/iframe2.php?trip_id=#{h trip_id}&width=#{size[0]}&height=#{size[1]}" marginheight=0 marginwidth=0 frameborder=0 scrolling=no width=#{size[0]} height=#{size[1]}>#{l}</iframe>|
end
