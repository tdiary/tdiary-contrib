# livedoor_weather.rb
#
# insert weather information using livedoor weather web service.
#
# Copyright (C) 2007 SHIBATA Hiroshi <h-sbt@nifty.com>
# You can redistribute it and/or modify it under GPL2.
#
require 'open-uri'
require 'timeout'
require 'rexml/document'

def lwws_init
	@conf['lwws.city_id'] ||= 63
	@conf['lwws.icon.disp'] ||= ""
	@conf['lwws.max_temp.disp'] ||= ""
	@conf['lwws.min_temp.disp'] ||= ""
	@conf['lwws.cache'] ||= ""
	@conf['lwws.cache_time'] ||= 6
end

def convert_date( date_status )
	case date_status
	when "today"
		date = Time.now
	when "tomorrow"
		date = Time.now + (60 * 60 * 24)
	when "dayaftertomorrow"
		date = Time.now + (60 * 60 * 24 * 2)
	end
	return date.strftime("%Y%m%d")
end

def lwws_request( city_id, date_status )
	url =  @lwws_rest_url.dup
	url << "?city=#{city_id}"
	url << "&day=#{date_status}"

	proxy = @conf['proxy']
	proxy = 'http://' + proxy if proxy
	timeout( 10 ) do
		open( url, :proxy => proxy ) {|f| f.read }
	end
end

def lwws_get( date_status , update = false)
	lwws_init

	city_id = @conf['lwws.city_id']
	cache_time = @conf['lwws.cache_time'] * 60 * 60  # hour

	cache = "#{@cache_path}/lwws"
	file_name = "#{cache}/#{convert_date( date_status )}.xml" # file_name is YYYYMMDD.xml

	begin
		Dir::mkdir( cache ) unless File::directory?( cache )
		cached_time = nil
		cached_time = File.mtime( file_name ) if File.exist?( file_name )

		unless cached_time.nil?
			if @conf['lwws.cache'] == "t" and Time.now > cached_time + cache_time
				update = true
			end
		end

		if cached_time.nil? or update
			xml =  lwws_request( city_id, date_status )
			File::open( file_name, 'wb' ) {|f| f.write( xml )}
		end
	rescue Timeout::Error
		return
	rescue NoMethodError
		return
	end
end

def lwws_to_html( date_status, date = nil )
	lwws_init

	cache = "#{@cache_path}/lwws"

	if date == nil
		file_name = "#{cache}/#{convert_date( date_status)}.xml" # file_name is YYYYMMDD
	else
		file_name = "#{cache}/#{date}.xml"
	end

	begin
		xml = File::read( file_name )
		doc = REXML::Document::new( xml ).root

		telop = @conf.to_native( doc.elements["telop"].text, 'utf-8' )
		max_temp = doc.elements["temperature/max/celsius"].text
		min_temp = doc.elements["temperature/min/celsius"].text
		detail_url = doc.elements["link"].text

		result = ""
		result << %Q|<div class=\"lwws\">|

		if @conf['lwws.icon.disp'] != "t" || @conf.mobile_agent? then
			result << %Q|<a href="#{h(detail_url)}">#{telop}</a>|
		else
			title = @conf.to_native( doc.elements["image/title"].text, 'utf-8' )
			link = doc.elements["image/link"].text
			url = doc.elements["image/url"].text
			width = doc.elements["image/width"].text
			height = doc.elements["image/height"].text
			result << %Q|<a href="#{link}"><img src="#{url}" border="0" alt="#{title}" title="#{title}" width=#{width} height="#{height}" /></a>|
		end

		if @conf['lwws.max_temp.disp'] == "t" then
			unless max_temp == nil
				result << %Q| #{@lwws_max_temp_label}:#{h(max_temp)}#{@celsius_label}|
			end
		end
		if @conf['lwws.min_temp.disp'] == "t" then
			unless min_temp == nil
				result << %Q| #{@lwws_min_temp_label}:#{h(min_temp)}#{@celsius_label}|
			end
		end

		result << %Q|</div>|

		return result
	rescue Errno::ENOENT
		return ''
	end
end

def lwws_today
	lwws_get( "today" )
	lwws_to_html( "today" )
end

def lwws_tomorrow
	lwws_get( "tomorrow" )
	lwws_to_html( "tomorrow" )
end

def lwws_dayaftertomorrow
	lwws_get( "dayaftertomorrow" )
	lwws_to_html( "dayaftertomorrow" )
end

def lwws( date )
	lwws_to_html( "", date )
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

		lwws_get( "today", true)
		lwws_get( "tomorrow", true)
		lwws_get( "dayaftertomorrow", true)
	end

	result = ''

	result << <<-HTML
	<h3>#{@lwws_label_city_id}</h3>
	<p>#{@lwws_desc_city_id}</p>
	<p><input name="lwws.city_id" value="#{h(@conf['lwws.city_id'])}"></p>
	HTML

	result << %Q|<h3>#{@lwws_icon_label}</h3>|
	checked = "t" == @conf['lwws.icon.disp'] ? ' checked' : ''
	result << %Q|<p><label for="lwws.icon.disp"><input id="lwws.icon.disp" name="lwws.icon.disp" type="checkbox" value="t"#{checked} >#{@lwws_icon_desc}</label></p>|

	result << %Q|<h3>#{@lwws_label_disp_item}</h3>|
	result << %Q|<p>#{@lwws_desc_disp_item}</p>|
	result << %Q|<ul>|
	checked = "t" == @conf['lwws.max_temp.disp'] ? ' checked' : ''
	result << %Q|<li><label for="lwws.max_temp.disp"><input id="lwws.max_temp.disp" name="lwws.max_temp.disp" type="checkbox" value="t"#{checked} >#{@lwws_max_temp_label}</label></li>|
	checked = "t" == @conf['lwws.min_temp.disp'] ? ' checked' : ''
	result << %Q|<li><label for="lwws.min_temp.disp"><input id="lwws.min_temp.disp" name="lwws.min_temp.disp" type="checkbox" value="t"#{checked} >#{@lwws_min_temp_label}</label></li>|
	result << %Q|</ul>|

	result << %Q|<h3>#{@lwws_label_cache}</h3>|
	checked = "t" == @conf['lwws.cache'] ? ' checked' : ''
	result << %Q|<p><label for="lwws.cache"><input id="lwws.cache" name="lwws.cache" type="checkbox" value="t"#{checked} >#{@lwws_desc_cache}</label></p>|
	result << %Q|<p>#{@lwws_desc_cache_time}</p>|
	result << %Q|<p><input name="lwws.cache_time" value="#{h(@conf['lwws.cache_time'])}"></p>|

	return result
end

add_body_enter_proc do |date|
	unless feed?
		lwws_to_html( "", date.strftime("%Y%m%d"))
	end
end

add_update_proc do
	lwws_get( "today" )
end

add_conf_proc( 'lwws', @lwws_plugin_name ) do
	lwws_conf_proc
end
