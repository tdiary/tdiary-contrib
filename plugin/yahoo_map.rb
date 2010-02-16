#
# yahoo_map.rb - embeded Yahoo! Japan Map for tDiary
#
# Copyright (C) 2010, KAYA Satoshi <kayakaya@kayakaya.net>
# You can redistribute it and/or modify it under GPL2.
#

add_header_proc do
   init_ymap
   if @conf['yahoo_jp.appid'] and @conf['yahoo_jp.appid'].size > 0
      %Q|<script type="text/javascript"
       src="http://map.yahooapis.jp/MapsService/js/V2/?appid= #{h @conf['yahoo_jp.appid']}"></script>|
   else
      ''
   end
end

add_conf_proc( 'yahoo_jp_appid', 'Yahoo! Japan Application ID' ) do
   if @mode == 'saveconf' then
      @conf['yahoo_jp.appid'] = @cgi.params['yahoo_jp.appid'][0]
   end

   <<-HTML
   <h3 class="subtitle">Yahoo! Japan Application ID</h3>
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

def yahoo_map(lat, lon, size = 'medium', layer = 3)
   # define map size
   height = {'small'=> '240px', 'medium' => '360px', 'large' => '480px'}
   width = {'small' => '320px', 'medium' => '480px', 'large' => '640px'}
   if @conf.iphone? then
      size = 'small'
   end

   # generate id from latitude and longtitude because cobination is uniq.
   ymapid = "ymapid" + lat.to_s + lon.to_s + layer.to_s
   ymapid.gsub!(/\./,'')
   ymap_info = {:ymapid => ymapid, :lat => lat, :lon => lon, :layer => layer}

   @ymap_container << ymap_info

   r = %Q|<div class="ymap" id="#{ymapid}" style="width:#{width[size]}; height:#{height[size]}"></div>|
   return r
end

def insert_ymap_js
   if @ymap_container.size > 0 then
      unless feed? then
         r = %Q|<script type="text/javascript">\n|
         r << %Q|function defineYmapIds() {\n|
         @ymap_container.each do |ymap_info|
            r << %Q|#{ymap_info[:ymapid]} = new YahooMapsCtrl("#{ymap_info[:ymapid]}", "#{ymap_info[:lat]}, #{ymap_info[:lon]}", #{ymap_info[:layer]}, YMapMode.MAP, YDatumType.WGS84);\n|
         end
         r << %Q|}\n|
         r << %Q|if (window.addEventListener) window.addEventListener('load', defineYmapIds , false);\n|
         r << %Q|</script>|
         return r
      end
   else
      ''
   end
end
# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
