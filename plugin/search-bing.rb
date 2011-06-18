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
require 'rexml/document'
require 'net/http'
Net::HTTP.version_1_2

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

def search_bing_market
	'ja-JP'
end

def search_bing_api( q, start = 0 )
	url = 'http://api.bing.net/xml.aspx'
	appid = @conf['search-bing.appid']

	url << "?AppId=#{appid}&Version=2.2&Market=#{search_bing_market}&Query=#{q}&Sources=web&Web.Count=20&Web.Offset=#{start}"

	proxy = @conf['proxy']
	proxy = 'http://' + proxy if proxy
	
	proxy_host, proxy_port = nil
	if proxy
		proxy_host = proxy_uri.host
		proxy_port = proxy_uri.port
	end
	proxy_class = Net::HTTP::Proxy(proxy_host, proxy_port)

	query = URI.parse(url)
	req = Net::HTTP::Get.new(query.request_uri)
	http = proxy_class.new(query.host, query.port)
	http.open_timeout = 20
	http.read_timeout = 20
	res = http.start do
		http.request(req)
	end
	res.body
end

def search_to_html( str )
	(str || '').gsub( /(?:<wbr(?:[ \t\r\n][^>]*)?>)+/, '' ).gsub( %r{<(/?)b[ \t\n\r]*>}, '<\\1strong>' )
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
		doc = REXML::Document::new( REXML::Source.new( xml ) ).root
	rescue OpenURI::HTTPError
		return %Q|<p class="message">#$!</p>|
	end

	r = search_input_form( query )
	r << '<dl class="search-result autopagerize_page_element">'
	doc.elements.to_a( '*/web:Results/web:WebResult' ).each do |elem|
		url = elem.elements.to_a( 'web:Url' )[0].text
		next unless url =~ @conf['search.result_filter']
		title = elem.elements.to_a( 'web:Title' )[0].text
		desc = elem.elements.to_a( 'web:Description' )[0].text
		r << %Q|<dt><a href="#{h url}">#{search_to_html title}</a></dt>|
		r << %Q|<dd>#{search_to_html desc}</dd>|
	end
	r << '</dl>'
	
	r << '<div class="search-navi">'
	total = doc.elements.to_a( 'web:Web/web:Total' )[0].text.to_i
	total = 1000 if total > 1000
	offset = doc.elements.to_a( 'web:Web/web:Offset' )[0].text.to_i

	if offset - 20 >= 0 then
		r << %Q|<a href="#{@conf.index}?q=#{u query}&amp;start=#{offset-20}" rel="prev">&lt;前の20件</a>&nbsp;|
	end

	if offset + 20 < total then
		r << %Q|<a href="#{@conf.index}?q=#{u query}&amp;start=#{offset+20}" rel="next">次の20件&gt;</a>|
	end
	r << '</div>'

	r
end
