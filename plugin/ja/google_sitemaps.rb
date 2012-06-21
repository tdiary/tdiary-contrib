# google_sitemap.rb
# Copyright (c) 2006 http://d.bulkitem.com/
# Distributed under the GPL

add_conf_proc('google_sitemaps', 'Google sitemap') do
  saveconf_google_sitemaps

  request_uri = File::dirname(@cgi.request_uri)
  if request_uri == "/"
    @conf['google_sitemaps.uri_format'] ||= 'http://' + @cgi.server_name + '/index.cgi?date=%s'
  else
    @conf['google_sitemaps.uri_format'] ||= 'http://' + @cgi.server_name + request_uri + '/index.cgi?date=%s'
  end
  @conf['google_sitemaps.output_file'] ||= File::dirname(ENV['SCRIPT_FILENAME']) + '/sitemap.xml'

  if File.writable_real?(@conf['google_sitemaps.output_file']) == false
    msg = "<strong>[NG] 指定されているファイルの書き込み権限がありません。</strong>"
  else
    msg = "[OK] 指定されているファイルの書き込み権限があります。"
  end

  <<-HTML
  <p>Google ウェブマスターツール用のSitemap XMLを出力する設定を行います。</p>
  <h3 class="subtitle">アドレスフォーマット</h3>
  <p>日付別表示時のURLフォーマットを指定します。日付文字列の部分は<strong>%s</strong>にしてください。</p>
  <p><input type="text" name="google_sitemaps.uri_format" value="#{ CGI::escapeHTML(@conf['google_sitemaps.uri_format']) }" size="50"></p>
  <div class="section">eg.<br>http://www.example.com/inex.cgi?date=<strong>%s</strong><br>http://www.example.com/<strong>%s</strong>.html</div>

  <h3 class="subtitle">XMLファイルの出力先</h3>
  <p>出力するファイルを絶対パスで指定します。</p>
  <p><input type="text" name="google_sitemaps.output_file" value="#{ CGI::escapeHTML(@conf['google_sitemaps.output_file']) }" size=\"50\"></p>
  <p>#{msg}</p>
  HTML

end
