# -*- coding: utf-8 -*-
#
# search-yahoo-websearch.rb - Yahoo!デベロッパーネットワークのWeb検索APIを利用した検索プラグイン.
#
# Copyright (C) 2011, hb <smallstyle@gmail.com>
# You can redistribute it and/or modify it under GPL.
#
# オプション
#
# @options['search-yahoo-websearch.appid'] : アプリケーションID（必須）
# @options['search-yahoo-websearch.premium'] : アップグレード版利用時はtrueを指定する（任意）
#

def search_title
	'全文検索 by Yahoo! ウェブ検索'
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

def request_url
	if @conf['search-yahoo-websearch.premium']
		'http://search.yahooapis.jp/PremiumWebSearchService/V1/webSearch'
	else
		'http://search.yahooapis.jp/WebSearchService/V2/webSearch'
	end
end

def search_to_html( str )
	(str || '').gsub( /(?:<wbr(?:[ \t\r\n][^>]*)?>)+/, '' ).gsub( %r{<(/?)b[ \t\n\r]*>}, '<\\1strong>' )
end

def yahoo_websearch_api( q, start = 1 )
	url = request_url
	appid = @conf['search-yahoo-websearch.appid']
	uri = URI::parse( @conf.base_url )
	
	url << "?appid=#{appid}&query=#{q}&results=20&start=#{start}&format=html&site=#{uri.host}"

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

def yahoo_websearch_attribution
	<<-EOF
		<!-- Begin Yahoo! JAPAN Web Services Attribution Snippet -->
		<a href="http://developer.yahoo.co.jp/about">
		<img src="http://i.yimg.jp/images/yjdn/yjdn_attbtn1_125_17.gif" title="Webサービス by Yahoo! JAPAN" alt="Web Services by Yahoo! JAPAN" width="125" height="17" border="0" style="margin:15px 15px 15px 15px"></a>
		<!-- End Yahoo! JAPAN Web Services Attribution Snippet -->
	EOF
end

def search_result
	query = CGI::unescape( @cgi.params['q'][0] )
	start = CGI::unescape( @cgi.params['start'][0] || '1' ).to_i
	
   begin
		uri = URI::parse( @conf.base_url )
		xml = yahoo_websearch_api( u( query.untaint ), start )
		doc = REXML::Document::new( REXML::Source.new( xml ) ).root
		err = doc.elements.to_a( '/Error/Message' )[0]
		if err
			return %Q|<p class="message">ERROR - #{err.text}</p>|
		end
	rescue OpenURI::HTTPError
		return %Q|<p class="message">#$!</p>|
	end
	
	r = '<dl class="search-result autopagerize_page_element">'
	doc.elements.to_a( 'Result' ).each do |elem|
		url = elem.elements.to_a( 'Url' )[0].text
		next unless url =~ @conf['search.result_filter']
		title = elem.elements.to_a( 'Title' )[0].text
		summary = elem.elements.to_a( 'Summary' )[0].text
		r << %Q|<dt><a href="#{h url}">#{search_to_html title}</a></dt>|
		r << %Q|<dd>#{search_to_html summary}</dd>|
	end
	r << '</dl>'
	
	r << '<div class="search-navi">'
	pos = doc.elements["/ResultSet"].attributes["firstResultPosition"]
	unless pos == '1'
		r << %Q|<a href="#{@conf.index}?q=#{u query}&amp;start=#{pos.to_i - 20}" rel="prev">&lt;前の20件</a>&nbsp;|
	end
		
	total = doc.elements["/ResultSet"].attributes["totalResultsAvailable"]
	ret = doc.elements["/ResultSet"].attributes["totalResultsReturned"]

	if ret.to_i == 20 and pos.to_i + 19 < 1000
		r << %Q|<a href="#{@conf.index}?q=#{u query}&amp;start=#{pos.to_i + 20}" rel="next">次の20件&gt;</a>|
	end
	r << '</div>'
	
	r << yahoo_websearch_attribution
	
	r
end
