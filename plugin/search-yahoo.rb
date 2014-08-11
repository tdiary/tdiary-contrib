# -*- coding: utf-8 -*-
#
# search-yahoo.rb - site search plugin sample using Yahoo! Search BOSS API.
#
# Copyright (C) 2009, TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL.
#
# Needed these options below:
#
# @options['search-yahoo.appid'] : Your BOSS APPID
# @options['search-yahoo.result_filter'] : your dialy's URL format of DAY mode into Regexp.
#

require 'timeout'
require 'rexml/document'
require 'net/http'
Net::HTTP.version_1_2

def search_title
	'全文検索 by Yahoo! Search BOSS'
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

def search_boss_api( q, start = 0 )
	url = 'http://boss.yahooapis.com/ysearch/web/v1/'
	appid = @conf['search-yahoo.appid']

	url << "#{q}?appid=#{appid}&format=xml&count=20&start=#{start}"

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
		q = "#{query} site:#{uri.host}"
		q << %Q| inurl:"#{uri.path}"| unless uri.path == '/'
		xml = search_boss_api( u( q.untaint ), start )
		doc = REXML::Document::new( REXML::Source.new( xml ) ).root
		res = doc.elements.to_a( '/ysearchresponse' )[0]
		unless res.attribute( 'responsecode' ).value == '200' then
			return '<p class="message">ERROR</p>'
		end
	rescue OpenURI::HTTPError
		return %Q|<p class="message">#$!</p>|
	end

	r = search_input_form( query )
	r << '<dl class="search-result autopagerize_page_element">'
	doc.elements.to_a( '*/result' ).each do |elem|
		url = elem.elements.to_a( 'url' )[0].text
		next unless url =~ @conf['search-yahoo.result_filter']
		title = elem.elements.to_a( 'title' )[0].text
		abstract = elem.elements.to_a( 'abstract' )[0].text
		r << %Q|<dt><a href="#{h url}">#{search_to_html title}</a></dt>|
		r << %Q|<dd>#{search_to_html abstract}</dd>|
	end
	r << '</dl>'

	r << '<div class="search-navi">'
	doc.elements.to_a( '/ysearchresponse/prevpage' ).each do |p|
		if /start=\d+/ =~ p.text then
			r << %Q|<a href="#{@conf.index}?q=#{u query}&amp;#$&" rel="prev">&lt;前の20件</a>&nbsp;|
		end
	end

	doc.elements.to_a( '/ysearchresponse/nextpage' ).each do |n|
		if /start=\d+/ =~ n.text then
			r << %Q|<a href="#{@conf.index}?q=#{u query}&amp;#$&" rel="next">次の20件&gt;</a>|
		end
	end
	r << '</div>'

	r
end
