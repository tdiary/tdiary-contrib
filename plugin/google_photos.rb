# -*- coding: utf-8 -*-
# show Google Photos
#
# Copyright (c) MATSUOKA Kohei <http://www.machu.jp/>
# Distributed under the GPL
#

@conf['google_photos.api_key'] = nil
@conf['google_photos.client_id'] = nil
@conf['google_photos.api_key'] ||= 'AIzaSyCJIwIQMND58yVOZ8oeemCcMXYl6YU0jMQ'
@conf['google_photos.client_id'] ||= '797614784971-a0lhq52knkcgber5imvfn8gcgf904tks.apps.googleusercontent.com'

def google_photos(src, width, height, alt="photo", place="photo")
	%Q|<img title="#{alt}" width="#{width}" height="#{height}" alt="#{alt}" src="#{src}" class="#{place} google">|
end

def google_photos_left(src, width, height, alt="photo")
	google_photos(src, width, height, alt, 'left')
end

def google_photos_right(src, width, height, alt="photo")
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
  <h3>APIキー</h3>
  <p><input type="text" name="google_photos.api_key" size="100" value="#{@conf['google_photos.api_key']}"></p>
  <h3>認証用クライアントID</h3>
  <p><input type="text" name="google_photos.client_id" size="100" value="#{@conf['google_photos.client_id']}"></p>
_HTML
end
