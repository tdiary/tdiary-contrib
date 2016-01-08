# -*- coding: utf-8 -*-
# livedoor_weather.rb
#
# insert weather information using livedoor weather web service.
#
# Copyright (C) 2007 SHIBATA Hiroshi <shibata.hiroshi@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#

require 'open-uri'
require 'timeout'
require 'time'

@lwws_rest_url = 'http://weather.livedoor.com/forecast/webservice/json/v1'

def lwws_init
	@conf['lwws.city_id'] ||= 130010
	@conf['lwws.icon.disp'] ||= ""
	@conf['lwws.max_temp.disp'] ||= ""
	@conf['lwws.min_temp.disp'] ||= ""
	@conf['lwws.cache'] ||= ""
	@conf['lwws.cache_time'] ||= 6
end

def lwws_request( city_id )
	url =  @lwws_rest_url.dup
	url << "?city=#{city_id}"

	proxy = @conf['proxy']
	proxy = 'http://' + proxy if proxy
	Timeout.timeout( 10 ) do
		open( url, :proxy => proxy ) {|f| f.read }
	end
end

def lwws_get
	lwws_init

	city_id = @conf['lwws.city_id']
	cache_time = @conf['lwws.cache_time'] * 60 * 60
	file_name = "#{@cache_path}/lwws/#{Time.now.strftime("%Y%m%d")}.json"

	begin
		Dir.mkdir("#{@cache_path}/lwws") unless File.directory?("#{@cache_path}/lwws")

		cached_time = if File.exist?( file_name )
							  File.mtime( file_name )
						  else
							  nil
						  end

		update = true if @conf['lwws.cache'] == "t" && cached_time && Time.now > cached_time + cache_time

		if cached_time.nil? || update
			json = lwws_request(city_id)
			File.open(file_name, 'wb') {|f| f.write(json)}
		end
	rescue => e
		@logger.error( e )
	end
end

def lwws_to_html(date)
	lwws_init

	file_name = "#{@cache_path}/lwws/#{date.strftime("%Y%m%d")}.xml"

	begin
		# http://weather.livedoor.com/help/restapi_close
		if Time.parse('20130331') < date
			file_name.sub!(/xml/, 'json')
			require 'json'
			doc = JSON.parse(File.read(file_name))

			telop = @conf.to_native( doc["forecasts"][0]["telop"], 'utf-8' )
			# 「今日」のデータに気温は含まれない場合がある
			max_temp = doc["forecasts"][0]["temperature"]["max"]["celsius"] rescue nil
			min_temp = doc["forecasts"][0]["temperature"]["min"]["celsius"] rescue nil
			detail_url = doc["link"]
			title = @conf.to_native( doc["forecasts"][0]["image"]["title"], 'utf-8' )
			url = doc["forecasts"][0]["image"]["url"]
			width = doc["forecasts"][0]["image"]["width"]
			height = doc["forecasts"][0]["image"]["height"]
		else
			require 'rexml/document'
			doc = REXML::Document.new(File.read(file_name)).root

			telop = @conf.to_native( doc.elements["telop"].text, 'utf-8' )
			max_temp = doc.elements["temperature/max/celsius"].text
			min_temp = doc.elements["temperature/min/celsius"].text
			detail_url = doc.elements["link"].text
			title = @conf.to_native( doc.elements["image/title"].text, 'utf-8' )
			url = doc.elements["image/url"].text
			width = doc.elements["image/width"].text
			height = doc.elements["image/height"].text
		end

		result = ""
		result << %Q|<div class="lwws">|
		if @conf['lwws.icon.disp'] != "t" then
			result << %Q|<a href="#{h(detail_url)}">#{telop}</a>|
		else
			result << %Q|<a href="#{h(detail_url)}"><img src="#{url}" border="0" alt="#{title}" title="#{title}" width=#{width} height="#{height}"></a>|
		end
		if @conf['lwws.max_temp.disp'] == "t" and not max_temp.nil? then
			result << %Q| #{@lwws_max_temp_label}:#{h(max_temp)}#{@celsius_label}|
		end
		if @conf['lwws.min_temp.disp'] == "t" and not min_temp.nil? then
			result << %Q| #{@lwws_min_temp_label}:#{h(min_temp)}#{@celsius_label}|
		end
		result << %Q|</div>|

		result
	rescue StandardError, Errno::ENOENT => e
		@logger.error( e )
		''
	end
end

def lwws_conf_proc
	lwws_init

	if @mode == 'saveconf' then
		@conf['lwws.city_id'] = @cgi.params['lwws.city_id'][0].to_i
		@conf['lwws.icon.disp'] = @cgi.params['lwws.icon.disp'][0]
		@conf['lwws.max_temp.disp'] = @cgi.params['lwws.max_temp.disp'][0]
		@conf['lwws.min_temp.disp'] = @cgi.params['lwws.min_temp.disp'][0]
		@conf['lwws.cache'] = @cgi.params['lwws.cache'][0]
		@conf['lwws.cache_time'] = @cgi.params['lwws.cache_time'][0].to_i
	end

	result = ''

	result << <<-HTML
	<h3>#{@lwws_label_city_id}</h3>
	<p>#{@lwws_desc_city_id}</p>
	<p><input name="lwws.city_id" value="#{h(@conf['lwws.city_id'])}"></p>
	HTML

	result << %Q|<h3>#{@lwws_icon_label}</h3>|
	checked = "t" == @conf['lwws.icon.disp'] ? ' checked' : ''
	result << %Q|<p><label for="lwws.icon.disp"><input id="lwws.icon.disp" name="lwws.icon.disp" type="checkbox" value="t"#{checked}>#{@lwws_icon_desc}</label></p>|
	result << %Q|<h3>#{@lwws_label_disp_item}</h3>|
	result << %Q|<p>#{@lwws_desc_disp_item}</p>|
	result << %Q|<ul>|
	checked = "t" == @conf['lwws.max_temp.disp'] ? ' checked' : ''
	result << %Q|<li><label for="lwws.max_temp.disp"><input id="lwws.max_temp.disp" name="lwws.max_temp.disp" type="checkbox" value="t"#{checked}>#{@lwws_max_temp_label}</label></li>|
	checked = "t" == @conf['lwws.min_temp.disp'] ? ' checked' : ''
	result << %Q|<li><label for="lwws.min_temp.disp"><input id="lwws.min_temp.disp" name="lwws.min_temp.disp" type="checkbox" value="t"#{checked}>#{@lwws_min_temp_label}</label></li>|
	result << %Q|</ul>|
	result << %Q|<h3>#{@lwws_label_cache}</h3>|
	checked = "t" == @conf['lwws.cache'] ? ' checked' : ''
	result << %Q|<p><label for="lwws.cache"><input id="lwws.cache" name="lwws.cache" type="checkbox" value="t"#{checked}>#{@lwws_desc_cache}</label></p>|
	result << %Q|<p>#{@lwws_desc_cache_time}</p>|
	result << %Q|<p><input name="lwws.cache_time" value="#{h(@conf['lwws.cache_time'])}"></p>|

	result
end

add_body_enter_proc do |date|
	unless feed? or bot?
		lwws_to_html(date)
	end
end

add_update_proc do
	lwws_get
end

add_conf_proc( 'lwws', @lwws_plugin_name ) do
	lwws_conf_proc
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
