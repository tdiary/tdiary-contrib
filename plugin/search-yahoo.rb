# -*- coding: utf-8 -*-
#
# search-yahoo.rb - site search plugin sample using Yahoo! Search BOSS API.
#
# Copyright (C) 2009, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL.
#
# Needed these options below:
#
# @options['search-yahoo.appid'] : Your BOSS APPID
# @options['search-yahoo.result_filter'] : your dialy's URL format of DAY mode into Regexp.
#

require 'open-uri'
require 'timeout'
require 'json'

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

	url << "#{q}?appid=#{appid}&count=50&start=#{start}"

	proxy = @conf['proxy']
	proxy = 'http://' + proxy if proxy
	timeout( 10 ) do
		open( url, :proxy => proxy ) {|f| f.read }
	end
end

def search_to_html( str )
	str.gsub( /<wbr>/, '' ).gsub( /<b>/, '<strong>' ).gsub( /<\/b>/, '</strong>' )
end

def search_result
	query = CGI::unescape( @cgi.params['q'][0] )
	start = CGI::unescape( @cgi.params['start'][0] || '0' ).to_i

	begin
		uri = URI::parse( @conf.base_url )
		q = "#{query} site:#{uri.host}"
		q << %Q| inurl:"#{uri.path}"| unless uri.path == '/'
		json = search_boss_api( u( q.untaint ), start )
	rescue OpenURI::HTTPError
		return %Q|<p class="message">#$!</p>|
	end

	doc = JSON( json )
	res = doc['ysearchresponse']
	unless res['responsecode'] == '200' then
		return '<p class="message">ERROR</p>'
	end

	r = search_input_form( query )
	r << '<dl class="search-result">'
	res['resultset_web'].each do |elem|
		url = elem['url']
		next unless url =~ @conf['search-yahoo.result_filter']
		title = elem['title']
		abstract = elem['abstract']
		r << %Q|<dt><a href="#{h url}">#{search_to_html title}</a></dt>|
		r << %Q|<dd>#{search_to_html abstract}</dd>|
	end
	r << '</dl>'

### PENDING ###
#	r << '<div class="search-navi">'
#	doc.elements.to_a( '/ysearchresponse/prevpage' ).each do |p|
#		if /start=\d+/ =~ p.text then
#			r << %Q|<a href="#{@conf.index}?q=#{u query}&#$&">&lt;前の50件</a>&nbsp;|
#		end
#	end
#
#	doc.elements.to_a( '/ysearchresponse/nextpage' ).each do |n|
#		if /start=\d+/ =~ n.text then
#			r << %Q|<a href="#{@conf.index}?q=#{u query}&#$&">次の50件&gt;</a>|
#		end
#	end
#	r << '</div>'

	r
end
