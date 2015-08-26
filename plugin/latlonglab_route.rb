#
# latlonglab_route.rb - tDiary plugin for LatLongLab Route
#
# Copyright (C) 2009, Michitaka Ohno <elpeo@mars.dti.ne.jp>
# Copyright (C) 2010, KAYA Satoshi <kayakaya@kayakaya.net>
# You can redistribute it and/or modify it under GPL2.
#

def route( id, w = 480, h = 480 )

  if feed?
    return %Q|<p><a href="http://latlonglab.yahoo.co.jp/route/watch?id=#{id}">Link to LatLongLab Route</a></p>|
  end

  if @conf.iphone?
    w = 240
    h = 380
  end

  <<-HTML
  <div class="latlonglab-route">
  <script type="text/javascript" charset="UTF-8" src="http://latlonglab.yahoo.co.jp/route/paste?id=#{id}&amp;width=#{w}&amp;height=#{h}"></script>
  </div>
  HTML
end
