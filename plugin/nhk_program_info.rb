# -*- coding: utf-8 -*-
#
# nhk_program_info.rb - embedded NHK program information
# refer to following URL.
# http://api-portal.nhk.or.jp/ja
#
# Copyright (C) 2014, tamoot <tamoot+tdiary@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#

require 'json'
require 'date'
require 'timeout'
require 'open-uri'


def nhk_program_info(id, service, area = nil)

   area = @conf['nhk_api.default.area'] if area.nil? || area == ""

   json = nil
   begin
      json = call_nhk_json(id, service, area)
   rescue
      return %Q|<p>#{__FILE__}: error, #{$!}</p>|
   end

   stime = DateTime::parse(json["start_time"]).strftime("%Y/%m/%d %H:%M:%S")
   etime = DateTime::parse(json["end_time"]).strftime("%Y/%m/%d %H:%M:%S")

   return <<-PROGRAM_HTML
   <div class="amazon-detail">
   <a href="#{json["program_url"]}">
   <img src="#{json["program_logo"]["url"]}" alt="#{@conf.to_native json["title"]}" class="amazon-detail left">
   <div class="amazon-detail-desc">
   <span class="amazon-title">#{h json["service"]["name"]} - #{h json["title"]}</span><br><br>
   <span class="amazon-title">#{h json["subtitle"]}</span><br><br>
   <span class="amazon-price">#{h stime} - #{etime}</span><br>
   <span class="amazon-price">#{h '情報提供:ＮＨＫ'}</span>
   </div>
   <br style="clear: left">
   </a>
   </div>
   PROGRAM_HTML

end

def call_nhk_json(id, service, area)

   data = nil
   nhk_endpoint = "http://api.nhk.or.jp/v1/pg/info/#{area}/#{service}/#{id}.json?key=#{@conf['nhk_api.id']}"

   nhk_cache_path = "#{@cache_path}/nhk"
   Dir::mkdir(nhk_cache_path) unless File::directory?(nhk_cache_path)

   cache = "#{nhk_cache_path}/#{area}_#{service}_#{id}.json"
   begin
      data = File.read(cache)
      File::delete(cache) if Time::now > File::mtime( cache ) + 60*60*24*30

   rescue
      open_param = [nhk_endpoint]
      open_param << {:proxy => "http://#{@conf['proxy']}"} if @conf['proxy']

      status = nil
      data = nil
      Timeout.timeout(10) do
         open(*open_param){ |ff| data = ff.read; status = ff.status[0] }
      end
      raise "API Error" if status.to_s != '200'
      File::open(cache, 'wb') {|f| f.write(data) }


   end

   JSON::parse(data)['list'][service][0]
end

add_conf_proc( 'nhk', 'NHK API' ) do
   if @mode == 'saveconf' then
      @conf['nhk_api.id'] = @cgi.params['nhk_api.id'][0]
      @conf['nhk_api.default.area'] = @cgi.params['nhk_api.default.area'][0]
   end

   <<-HTML
   <h3 class="subtitle">API key</h3>
   <p><input name="nhk_api.id" value="#{h @conf['nhk_api.id']}" size="70"></p>
   <p>Register your tDiary and get API key.</p>
   <a href="http://www2.nhk.or.jp/api/">Go NHK API settings.</a></p>
   <h3 class="subtitle">Default Area</h3>
   <p><input name="nhk_api.default.area" value="#{h @conf['nhk_api.default.area']}" size="70"></p>
   <a href="http://www2.nhk.or.jp/api/">Refer NHK API settings.</a></p>
   HTML

end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3

