#
# everytrail.rb: plugin embedding trip map on everytrail.com.
#
# Copyright (C) 2010 TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2.
#

def everytrail_adjust_size( size )
	s = size.collect {|i| i.to_i }
	s[0] = 400 if s[0] == 0
	s[1] = 300 if s[1] == 0
	if @conf.iphone? then
		s = [300, 300 * s[1] / s[0]]
	end
	s
end

def everytrail( trip_id, label = nil, size = [400,300] )
	size = everytrail_adjust_size( size )
	l = label ? %Q|<a href="http://www.everytrail.com/view_trip.php?trip_id=#{h trip_id}">#{h label}</a>| : ''
	%Q|<div class="everytrail"><iframe src="http://www.everytrail.com/iframe2.php?trip_id=#{h trip_id}&width=#{size[0]}&height=#{size[1]}" marginheight=0 marginwidth=0 frameborder=0 scrolling=no width=#{size[0]} height=#{size[1]}>#{l}</iframe></div>|
end

def everytrail_flash( trip_id, label = nil, size = [400,300] )
	size = everytrail_adjust_size( size )
	l = label ? %Q|<a href="http://www.everytrail.com/view_trip.php?trip_id=#{h trip_id}">#{h label}</a>| : ''
	%Q|<div class="everytrail"><object width="#{size[0]}" height="#{size[1]}" codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab"><param name="movie" value="http://www.everytrail.com/swf/widget.swf"/><param name="FlashVars" value="units=metric&mode=0&key=ABQIAAAAggE6oX7o-2CFkLBRN20X9BTCaWgBOrVzmDbJc0e41WeTNzCWNBSYkdZ8D6iOk2yqQd-kgDCXfoqiUQ&tripId=#{trip_id}"><embed src="http://www.everytrail.com/swf/widget.swf" quality="high" width="#{size[0]}" height="#{size[1]}" FlashVars="units=metric&mode=0&key=ABQIAAAAggE6oX7o-2CFkLBRN20X9BTCaWgBOrVzmDbJc0e41WeTNzCWNBSYkdZ8D6iOk2yqQd-kgDCXfoqiUQ&tripId=#{trip_id}" play="true"  quality="high" type="application/x-shockwave-flash" pluginspage="http://www.adobe.com/go/getflashplayer"></embed></object></div>|
end

def everytrail_widget( trip_id, latitude = nil, longtitude = nil, label = nil, size = [400, 300] )
   if @conf.iphone?
      return ''
   end

	size = everytrail_adjust_size( size )
   r = label ? %Q|<h3><a href="http://www.everytrail.com/view_trip.php?trip_id=#{h trip_id}">#{h label}</a></h3>| : ''
   lat_param = latitude ? "&startLat=#{latitude}" : ''
   lon_param = longtitude ? "&startLon=#{longtitude}" : ''

   r << %Q|<object width="#{size[0]}" height="#{size[1]}" codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab"><param name="movie" value="http://www.everytrail.com/swf/widget.swf"/><param name="FlashVars" value="tripId=#{h trip_id}&units=metric&mode=0#{lon_param}#{lat_param}&stats=off&mapType=Terrain"><embed src="http://www.everytrail.com/swf/widget.swf" quality="high" width="#{size[0]}" height="#{size[1]}" FlashVars="tripId=#{h trip_id}&units=metric&mode=0#{lon_param}#{lat_param}&stats=off&mapType=Terrain" play="true"  quality="high" type="application/x-shockwave-flash" pluginspage="http://www.adobe.com/go/getflashplayer"></embed></object><br/><a href="http://www.everytrail.com" >Map your trip with EveryTrail</a>|
      return r
end

