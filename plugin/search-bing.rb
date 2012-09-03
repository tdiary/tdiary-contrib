# -*- coding: utf-8 -*-
#
# search-bing.rb - site search plugin sample using Bing API.
#
# Copyright (C) 2011, TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL.
#
# Needed these options below:
#
# @options['search-bing.appid'] : Your Bing AppId
# @options['search.result_filter'] : your dialy's URL format of DAY mode into Regexp.
#

require 'timeout'
require 'json'
require 'open-uri'

def search_title
	'全文検索 by Bing'
end

def search_input_form( q )
	r = <<-HTML
		<form method="GET" action="#{@conf.index}"><div>
			検索キーワード:
			<input name="q" value="#{h q}">
			<input type="submit" value="OK">
		</div></form>
	HTML
end

def search_bing_api( q, start = 0 )
	appid = @conf['search-bing.appid']

	u = 'https://api.datamarket.azure.com/Data.ashx/Bing/SearchWeb/v1/Web'
	u << "?Query=%27#{q}%27&Options=%27EnableHighlighting%27&$top=50&$skip=#{start}&$format=Json"
	uri = URI( u )

	open( uri, {:http_basic_authentication => [appid, appid]} ).read

### FIX ME: this code failed on Timeout error, temporary using open-uri above.
#	px_host, px_port = (@conf['proxy'] || '').split( /:/ )
#	px_port = 8080 if px_host and !px_port
#	res = Net::HTTP::Proxy( px_host, px_port ).start( uri.host, uri.port ) do |http|
#		req = Net::HTTP::Get.new( uri.request_uri )
#		req.basic_auth( appid, appid )
#		res = http.request( req )
#	end
#	res.body
end

def search_to_html( str )
	(str || '').gsub( /\uE000/, '<strong>' ).gsub( /\uE001/, '</strong>' )
end

def search_result
	query = CGI::unescape( @cgi.params['q'][0] )
	start = CGI::unescape( @cgi.params['start'][0] || '0' ).to_i

	begin
		uri = URI::parse( @conf.base_url )
		#uri = URI::parse( 'http://sho.tdiary.net/' ) ### FOR DEBUGGING ###
		q = "#{query} site:#{uri.host}"
		q << %Q| inurl:"#{uri.path}"| unless uri.path == '/'
		xml = search_bing_api( u( q.untaint ), start )
		json = JSON::parse( xml )
	rescue Net::HTTPError
		return %Q|<p class="message">#$!</p>|
	end

	r = search_input_form( query )
	r << '<dl class="search-result autopagerize_page_element">'
	json['d']['results'].each do |entry|
		url = entry['Url']
		title = entry['Title']
		desc = entry['Description']
		r << %Q|<dt><a href="#{h url}">#{search_to_html title}</a></dt>|
		r << %Q|<dd>#{search_to_html desc}</dd>|
	end
	r << '</dl>'
	
	r << '<div class="search-navi">'
		# no search navi on Bing search because no total result not supported
	r << '</div>'

	r
end
