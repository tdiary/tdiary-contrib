#
# yahoo_kousei.rb -
#  Yahoo!JAPANデベロッパーネットワークの校正支援APIを利用して、
#  日本語文の校正作業を支援します。文字の入力ミスや言葉の誤用がないか、
#  わかりにくい表記や不適切な表現が使われていないかなどをチェックします。
#
# Copyright (c) 2010, hb <http://www.smallstyle.com/>
# Copyright (c) 2023, Takuya Ono <takuya-o@users.osdn.me>
# You can redistribute it and/or modify it under GPL.
#
# 設定:
#
# @options['yahoo_kousei.appid'] : アプリケーションID(必須)
#
# 設定値は https://developer.yahoo.co.jp/webapi/jlp/kousei/v2/kousei.html を参照
#

require 'timeout'
require 'json'
require 'net/http'
require 'net/https'
Net::HTTP.version_1_2

def kousei_api( sentence )
	appid = @conf['yahoo_kousei.appid']
        headers = {'Content-Type' => 'application/json',
                   'User-Agent' => "Yahoo AppID: #{appid}" }

        query = { "id" => 1234,
                  "jsonrpc" => "2.0",
                  "method" => "jlp.kouseiservice.kousei",
                  "params" => {
                    "q" => sentence
                  }
                }

	px_host, px_port = (@conf['proxy'] || '').split( /:/ )
	px_port = 80 if px_host and !px_port

	xml = ''
	Net::HTTP::Proxy( px_host, px_port ).start( 'jlp.yahooapis.jp',443, use_ssl: true , verify_mode: OpenSSL::SSL::VERIFY_PEER  ) do |http|
		xml = http.post( '/KouseiService/V2/kousei', query.to_json, headers ).body
	end
	xml
end

def kousei_result( result_set )
	html = <<-HTML
	<h3>文章校正結果</h3>
	HTML

	doc = JSON.parse( result_set )
        errormsg = ""
        if doc["Error"] != nil
          errormsg = doc["Error"]["Message"]
          doc = { "result" => { "suggestions" => [] } }
        end
	results = doc['result']['suggestions']
	if results.length == 0
          if errormsg == ""
	    html << "<p>指摘項目は見つかりませんでした。</p>"
          else
            html << "<p>Error: #{errormsg}</p>"
          end
	else
		html << '<table>'
		html << '<tr><th>対象表記</th><th>候補文字</th><th>詳細情報</th><th>場所</th></tr>'
		results.each do |r|
			html << %Q|<tr class="plugin_yahoo_search_result_raw"><td>#{r['word']}</td><td>#{r['suggestion']}</td><td>#{r['rule']} #{r['note']}</td><td>#{r['offset']},#{r['length']}</td></tr>|
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
