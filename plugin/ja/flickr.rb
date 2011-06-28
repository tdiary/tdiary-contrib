# flickr.rb Japanese resources

add_conf_proc('flickr', 'Flickr プラグイン') do

  if @mode == 'saveconf'
    @conf['flickr.default_size'] = @cgi.params['flickr.default_size'][0]
    @conf['flickr.user_id'] = @cgi.params['flickr.user_id'][0]
    if @cgi.params['flickr.clear'][0] == "true"
      flickr_clear_cache
    end
  end

  flickr_bookmarklet = CGI.escapeHTML %Q{javascript:(function(){var w=window;w.page_photo_id||/^\/photos\/[^/]+\/(\d+)\//.test(w.location.pathname)?w.location.href="#{@conf.base_url}#{@update}?#{FLICKER_FORM_PID}="+w.page_photo_id||RegExp.$1:void(0);})()}
  r = <<-_HTML
  <p><a href="http://www.flickr.com/">Flickr</a> に登録した画像を日記に表示するプラグインです。日記の本文中で下記のように呼び出します。</p>
  <pre>&lt;%=flickr 画像ID, 画像サイズ%&gt;</pre>
  <dl>
    <dt>画像ID</dt>
      <dd>それぞれの写真に一意に付けられる番号です。<br>画像IDは Flickr で画像を表示したときの URL に含まれています。</dd>
    <dt>画像サイズ</dt>
      <dd>表示する画像の大きさを square, thumbnail, small, medium, large から指定します。<br>この値は省略できます。省略すると、画像は設定画面（この画面）で指定したサイズで表示されます。</dd>
  </dl>

  <h3>標準の画像サイズ</h3>
  <p>画像サイズを省略してプラグインを呼び出した場合のサイズを指定します。</p>
  <p>
  <select name="flickr.default_size">
  _HTML
  %w(square thumbnail small medium large).each do |size|
    selected = (size == @conf['flickr.default_size']) ? 'selected' : ''
    r << %Q|<option value="#{size}" #{selected}>#{size}</option>|
  end
  r <<<<-_HTML
  </select>
  </p>

  <!-- TODO: Loading... --->
  <h3>FlickrのユーザID</h3>
  <p>Flickr上でのあなたのユーザIDを入力してください。</p>
  <p><input type="text" name="flickr.user_id" size="20" value="#{@conf['flickr.user_id']}"></p>
  <div style="margin-left: 2em">
    <p>※ Flickr ID は「19594487@N00」のような文字列です。分からないときは <a href="http://idgettr.com/">idgettr.com</a> で調べることができます。</p>
  </div>

  <h3>Bookmarklet</h3>
  <p>写真をかんたんに tDiary の日記へ載せるための Bookmarklet です。Bookmarklet を登録しなくても Flickr プラグインは使えますが、登録すればより便利になります。</p>
  <p><a href="#{flickr_bookmarklet}">Flickr to tDiary</a> (このリンクをブラウザのお気に入り・ブックマークに登録してください)</p>
  <p>使い方</p>
  <ol>
    <li>Flickr にアクセスし、日記に載せたい写真のページを開いて、この Bookmarklet を実行してください。</li>
    <li>日記の編集フォームの下に先ほどの写真が表示されます。</li>
    <li>「本文に追加」ボタンを押すと、日記中にこの写真を表示するための記述（プラグイン）が追記されます。</li>
  </ol>

  <h3>キャッシュファイルの削除</h3>
  <p>Flickrプラグインが使用しているキャッシュを削除します。</p>
  <p>
    <input type="checkbox" id="flickr.clear" name="flickr.clear" value="true">
    <label for="flickr.clear">キャッシュを削除する</label>
  </p>
_HTML
end
