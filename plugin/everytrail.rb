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
   s
end

def everytrail( trip_id, label = nil, size = [400, 300] )
   size = everytrail_adjust_size( size )
   r = %Q|<div class="everytrail"><iframe src="http://www.everytrail.com/iframe2.php?trip_id=#{h trip_id}&amp;width=#{size[0]}&amp;height=#{size[1]}" marginwidth="0" marginheight="0" frameborder="0" scrolling="no" width=#{size[0]} height=#{size[1]}>|
   r << %Q|<a href="http://www.everytrail.com/view_trip.php?trip_id=#{h trip_id}">#{h label}</a>| if label
   r << %Q|</iframe></div>|
end

def everytrail_flash( trip_id, label = nil, size = [400, 300] )
   size = everytrail_adjust_size( size )
   %Q|<div class="everytrail"><object width="#{size[0]}" height="#{size[1]}" codebase="http://fpdownload.adobe.com/pub/shockwave/cabs/flash/swflash.cab"><param name="movie" value="http://www.everytrail.com/swf/widget.swf"><param name="FlashVars" value="units=metric&amp;mode=0&amp;key=ABQIAAAAggE6oX7o-2CFkLBRN20X9BTCaWgBOrVzmDbJc0e41WeTNzCWNBSYkdZ8D6iOk2yqQd-kgDCXfoqiUQ&amp;tripId=#{trip_id}"><embed src="http://www.everytrail.com/swf/widget.swf" quality="high" width="#{size[0]}" height="#{size[1]}" FlashVars="units=metric&amp;mode=0&amp;key=ABQIAAAAggE6oX7o-2CFkLBRN20X9BTCaWgBOrVzmDbJc0e41WeTNzCWNBSYkdZ8D6iOk2yqQd-kgDCXfoqiUQ&amp;tripId=#{trip_id}" play="true" quality="high" type="application/x-shockwave-flash" pluginspage="http://www.adobe.com/go/getflashplayer"></embed></object></div>|
end

def everytrail_widget( trip_id, latitude = nil, longtitude = nil, label = nil, size = [400, 300] )
   size = everytrail_adjust_size( size )
   lat_param = latitude ? "&amp;startLat=#{latitude}" : ''
   lon_param = longtitude ? "&amp;startLon=#{longtitude}" : ''
   r = label ? %Q|<h3><a href="http://www.everytrail.com/view_trip.php?trip_id=#{h trip_id}">#{h label}</a></h3>| : ''
   r << %Q|<object width="#{size[0]}" height="#{size[1]}" codebase="http://fpdownload.adobe.com/pub/shockwave/cabs/flash/swflash.cab"><param name="movie" value="http://www.everytrail.com/swf/widget.swf"><param name="FlashVars" value="tripId=#{h trip_id}&amp;units=metric&amp;mode=0#{lon_param}#{lat_param}&amp;stats=off&amp;mapType=Terrain"><embed src="http://www.everytrail.com/swf/widget.swf" quality="high" width="#{size[0]}" height="#{size[1]}" FlashVars="tripId=#{h trip_id}&amp;units=metric&amp;mode=0#{lon_param}#{lat_param}&amp;stats=off&amp;mapType=Terrain" play="true" quality="high" type="application/x-shockwave-flash" pluginspage="http://www.adobe.com/go/getflashplayer"></embed></object><br><a href="http://www.everytrail.com">Map your trip with EveryTrail</a>|
end

