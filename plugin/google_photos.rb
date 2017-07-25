# -*- coding: utf-8 -*-
# show Google Photos
#
# Copyright (c) MATSUOKA Kohei <http://www.machu.jp/>
# Distributed under the GPL
#

def google_photos(src, width, height, scale=70, alt="photo", place="photo")
	width = width.to_i * (scale.to_f / 100)
	height = height.to_i * (scale.to_f / 100)
	%Q|<img title="#{alt}" width="#{width}" height="#{height}" alt="#{alt}" src="#{src}" class="#{place} google">|
end

def google_photos_left(src, width, height, scale=70, alt="photo")
	width = width.to_i * (scale.to_f / 100)
	height = height.to_i * (scale.to_f / 100)
	google_photos(src, width, height, alt, 'left')
end

def google_photos_right(src, width, height, scale=70, alt="photo")
	width = width.to_i * (scale.to_f / 100)
	height = height.to_i * (scale.to_f / 100)
	google_photos(src, width, height, alt, 'right')
end

if /\A(form|edit|preview|showcomment)\z/ === @mode then
  enable_js('google_photos.js')
  add_js_setting('$tDiary.plugin.google_photos')
  add_js_setting('$tDiary.plugin.google_photos.api_key', @conf['google_photos.api_key'].to_json)
  add_js_setting('$tDiary.plugin.google_photos.client_id', @conf['google_photos.client_id'].to_json)

  add_footer_proc do
    '<script type="text/javascript" src="https://apis.google.com/js/api.js?onload=onApiLoad"></script>'
  end
end

add_edit_proc do |date|
  <<-FORM
	<div class="google_photos">
		<input id="google_photos" type="button" value="Googleフォト"></input>
	</div>
  FORM
end

add_conf_proc('google_photos', 'Googleフォト') do
  if @mode == 'saveconf'
    @conf['google_photos.api_key'] = @cgi.params['google_photos.api_key'][0]
    @conf['google_photos.client_id'] = @cgi.params['google_photos.client_id'][0]
  end

  r = <<-_HTML
	<h3>概要</h3>
	<p>Googleフォトの写真を日記に表示します。</p>
	<h3>機能</h3>
	<ul>
		<li>Googleフォトの写真を選択して日記に貼り付ける</li>
		<li>PC上の写真をGoogleフォトへアップロードする</li>
	</ul>
	<h3>制約事項</h3>
	<ul>
		<li>サムネイルを使用しているため、サイズが512pxまでしか表示できません</li>
	</ul>
	<h3>使い方</h3>
	<p>
		このプラグインを使うためには、Google Developers ConsoleからAPIキーと認証用クライアントIDを取得する必要があります。
		手順は<a href="https://www.evernote.com/shard/s18/sh/7211b9c3-fb75-4af8-aa55-718ff6c81aac/77c3a51871f0f245">Googleフォトプラグインを利用するためのAPIキーとクライアントIDの取得手順</a>を参考にしてください。
	</p>
	<h3>APIキー</h3>
	<p><input type="text" name="google_photos.api_key" size="100" value="#{@conf['google_photos.api_key']}"></p>
	<h3>認証用クライアントID</h3>
	<p><input type="text" name="google_photos.client_id" size="100" value="#{@conf['google_photos.client_id']}"></p>
_HTML
end
