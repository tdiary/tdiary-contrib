#
# yahoo_kousei.rb - 
#  Yahoo!JAPANデベロッパーネットワークの校正支援APIを利用して、
#  日本語文の校正作業を支援します。文字の入力ミスや言葉の誤用がないか、
#  わかりにくい表記や不適切な表現が使われていないかなどをチェックします。
#
# Copyright (c) 2010, hb <http://www.smallstyle.com/>
# You can redistribute it and/or modify it under GPL.
#
# 設定:
#
# @options['yahoo_kousei.appid'] : アプリケーションID(必須)
# @options['yahoo_kousei.filter_group'] :
#  指摘グループの番号をコンマで区切って指定します。
# @options['yahoo_kousei.no_filter'] :
#  filter_groupで指定した指摘グループから除外する指摘を指定します。
#
# 設定値は http://developer.yahoo.co.jp/webapi/jlp/kousei/v1/kousei.html を参照
#

require 'timeout'
require 'rexml/document'
require 'net/http'
Net::HTTP.version_1_2

def kousei_api( sentence )
	appid = @conf['yahoo_kousei.appid']

	query = "appid=#{appid}&sentence=#{URI.encode( sentence.gsub( /\n/, '' ) )}"
	query << "&filter_group=" + @conf['yahoo_kousei.filter_group'] if @conf['yahoo_kousei.filter_group']
	query << "&no_filter=" + @conf['yahoo_kousei.no_filter'] if @conf['yahoo_kousei.no_filter']

	px_host, px_port = (@conf['proxy'] || '').split( /:/ )
	px_port = 80 if px_host and !px_port
	
	xml = ''
	Net::HTTP::Proxy( px_host, px_port ).start( 'jlp.yahooapis.jp' ) do |http|
		xml = http.post( '/KouseiService/V1/kousei', query ).body
	end
	xml
end

def kousei_result( result_set )
	html = <<-HTML
	<h3>文章校正結果</h3>
	HTML

	doc = REXML::Document::new( result_set )
	results = REXML::XPath.match( doc, "//Result" )
	if results.empty?
		html << "<p>指摘項目は見つかりませんでした。</p>"
	else
		html << '<table>'
		html << '<tr><th>対象表記</th><th>候補文字</th><th>詳細情報</th><th>場所</th></tr>'
		doc.elements.each( '//ResultSet/Result' ) do |r|
			html << %Q|<tr class="plugin_yahoo_search_result_raw"><td>#{r.elements['Surface'].text}</td><td>#{r.elements['ShitekiWord'].text}</td><td>#{r.elements['ShitekiInfo'].text}</td><td>#{r.elements['StartPos'].text},#{r.elements['Length'].text}</td></tr>|
		end
		html << '</table>'
	end
	html
end

add_edit_proc do
	if @mode == 'preview' && @conf['yahoo_kousei.appid'] then
		xml = kousei_api( @cgi.params['body'][0] )
		<<-HTML
<div id="plugin_yahoo_kousei" class="section">
#{kousei_result( xml )}
<!-- Begin Yahoo! JAPAN Web Services Attribution Snippet -->
<span style="margin:15px 15px 15px 15px"><a href="http://developer.yahoo.co.jp/about">Webサービス by Yahoo! JAPAN</a></span>
<!-- End Yahoo! JAPAN Web Services Attribution Snippet -->
</div>
		HTML
	end
end

if /\A(form|edit|preview|showcomment)\z/ === @mode then
	enable_js( 'yahoo_kousei.js' )
end
