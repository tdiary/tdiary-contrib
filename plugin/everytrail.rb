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

def everytrail_widget( trip_id, latitude = nil, longtitude = nil, label = nil, size = [400, 300] )
   if @conf.iphone?
      return ''
   end

   size.collect! {|i| i.to_i }
   size[0] = 400 if size[0] == 0
   size[1] = 300 if size[1] == 0
   r = label ? %Q|<h3><a href="http://www.everytrail.com/view_trip.php?trip_id=#{h trip_id}">#{h label}</a></h3>| : ''
   lat_param = latitude ? "&startLat=#{latitude}" : ''
   lon_param = longtitude ? "&startLon=#{longtitude}" : ''

   r << %Q|<object width="#{size[0]}" height="#{size[1]}" codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab"><param name="movie" value="http://www.everytrail.com/swf/widget.swf"/><param name="FlashVars" value="tripId=#{h trip_id}&units=metric&mode=0#{lon_param}#{lat_param}&stats=off&mapType=Terrain"><embed src="http://www.everytrail.com/swf/widget.swf" quality="high" width="#{size[0]}" height="#{size[1]}" FlashVars="tripId=#{h trip_id}&units=metric&mode=0#{lon_param}#{lat_param}&stats=off&mapType=Terrain" play="true"  quality="high" type="application/x-shockwave-flash" pluginspage="http://www.adobe.com/go/getflashplayer"></embed></object><br/><a href="http://www.everytrail.com" >Map your trip with EveryTrail</a>|
      return r
end

