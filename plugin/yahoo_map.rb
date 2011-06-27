# -*- coding: utf-8 -*-
#
# yahoo_map.rb - embeded Yahoo! JAPAN Map for tDiary
#
# Copyright (C) 2010, KAYA Satoshi <kayakaya@kayakaya.net>
# You can redistribute it and/or modify it under GPL2.
#

add_header_proc do
   init_ymap
   r = ''
   if @conf['yahoo_jp.appid'] and @conf['yahoo_jp.appid'].size > 0
      r << %Q|<script type="text/javascript" charset="utf-8"|
      r << %Q| src="http://js.api.olp.yahooapis.jp/OpenLocalPlatform/V1/jsapi?appid=#{h @conf['yahoo_jp.appid']}"></script>|
   end
end

add_conf_proc( 'yahoo_jp_appid', 'Yahoo! JAPAN Application ID' ) do
   if @mode == 'saveconf' then
      @conf['yahoo_jp.appid'] = @cgi.params['yahoo_jp.appid'][0]
   end

   <<-HTML
   <h3 class="subtitle">Yahoo! JAPAN Application ID</h3>
   <p><input name="yahoo_jp.appid" value="#{h @conf['yahoo_jp.appid']}" size="70"></p>
   <p><a href="http://e.developer.yahoo.co.jp/webservices/register_application">Get Application id</a></p>
   HTML
end

add_footer_proc do |date|
   insert_ymap_js
end

def init_ymap
   @ymap_container = Array.new
end

def generate_ymapid(lat, lon, layer, size)
   ymapid = 'ymapid' << lat.to_s << lon.to_s << layer.to_s << size
   ymapid.delete('.')
end

def yahoo_map(lat, lon, options = {})
   options[:layer] ||= 17
   options[:size] ||= 'medium'

   if feed? or @conf.mobile_agent? then
      return %Q|<p><a href="http://map.yahoo.co.jp/pl?type=scroll&amp;lat=#{lat}&amp;lon=#{lon}&amp;z=17&amp;mode=map&amp;pointer=on&amp;datum=wgs&amp;fa=ks&amp;home=on&amp;hlat=#{lat}&amp;hlon=#{lon}&amp;layout=&amp;ei=utf-8&amp;p=">Link to Yahoo! JAPAN Map </a></p>|
   end

   # define map size
   height = {'iphone' => '240px', 'small'=> '240px', 'medium' => '360px', 'large' => '480px'}
   width = {'iphone' => '240px', 'small' => '320px', 'medium' => '480px', 'large' => '640px'}
   if @conf.iphone? then
      size = 'iphone'
   else
      size = options[:size]
   end

   ymapid = generate_ymapid(lat, lon, options[:layer], options[:size])
   ymap_info = {:ymapid => ymapid, :lat => lat, :lon => lon, :layer => options[:layer]}

   @ymap_container << ymap_info

   %Q|<div class="ymap" id="#{ymapid}" style="width:#{width[size]}; height:#{height[size]}"></div>|
end

def insert_ymap_js
   r = ''
   if @ymap_container.size > 0 and not feed? then
      r << %Q|<script type="text/javascript">\n|
      r << %Q|function defineYmapIds() {\n|
      @ymap_container.each do |ymap_info|
         r << %Q|  var obj#{ymap_info[:ymapid]} = new Y.Map("#{ymap_info[:ymapid]}");\n|
         r << %Q|  obj#{ymap_info[:ymapid]}.drawMap(new Y.LatLng(#{ymap_info[:lat]}, #{ymap_info[:lon]}), #{ymap_info[:layer]}, Y.LayerSetId.NORMAL);\n|
         r << %Q|  objCenterMarkControl = new Y.CenterMarkControl();\n|
         r << %Q|  objLayerSetControl = new Y.LayerSetControl();\n|
         r << %Q|  objScaleControl = new Y.ScaleControl();\n|
         r << %Q|  objZoomControl = new Y.SliderZoomControlVertical();\n|
         r << %Q|  obj#{ymap_info[:ymapid]}.addControl(objCenterMarkControl);\n|
         r << %Q|  obj#{ymap_info[:ymapid]}.addControl(objLayerSetControl);\n|
         r << %Q|  obj#{ymap_info[:ymapid]}.addControl(objScaleControl);\n|
         r << %Q|  obj#{ymap_info[:ymapid]}.addControl(objZoomControl);\n|
      end
      r << %Q|}\n|
      r << %Q|if (window.addEventListener) window.addEventListener("load", defineYmapIds, false); // for DOM level 2 compliant Web browsers\n|
      r << %Q|else if (window.attachEvent) window.attachEvent("onload", defineYmapIds); // for IE\n|
      r << %Q|</script>|
   end
end
# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
