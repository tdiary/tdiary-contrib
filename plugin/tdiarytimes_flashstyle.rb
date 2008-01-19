# tdiarytimes_flashstyle.rb $Revision: 1.2 $
#
# Copyright (c) 2004 phonondrive <tdiary@phonondrive.com>
# Distributed under the GPL
#
# プラグイン配布ページ：
# http://phonondrive.com/trd/
# --------------------------------------------------------------------
#
#
#
# Abstract：
# --------------------------------------------------------------------
# 日記を登録した時間帯をタイムライン上に記録します。記録されたエントリは
# 日時の経過と共にフェードアウトしていきます。このような MTBlogTimes や 
# tdiarytimes.rb と同等の機能を FLASH で実現します。
# ruby-gd のインストール作業も必要ないため、すぐに使用出来ます。
#
#
# Usage：
# --------------------------------------------------------------------
# プラグインは、プラグインフォルダに入れて下さい。
#
# プラグインは、プラグインフォルダに入れてください。
# tdiarytimes*.swf を tdiary.rb と同じフォルダにアップロードします。
# ヘッダ、フッタ部に記述した <%= tdiarytimes_flashstyle %> の部分に、
# FLASH アプレットが表示されます。
# tdiarytimes.log は日記登録時に .swf と同じフォルダに作成されます。
#
# ※ tdiarytimes_textstyle.rb との互換性はありません。
#
#
# Options：
# --------------------------------------------------------------------
# タイムラインの色、透明度、サイズなどは、プリファレンス画面で設定できます。
#
#
# In secure mode：
# --------------------------------------------------------------------
# たぶん動作しません。
#
#
=begin ChangeLog
2004.05.02 phonondrive  <tdiary@phonondrive.com>
   * version 1.1.2
		タイムラインが曜日別の FLASH を追加
2004.05.02 phonondrive  <tdiary@phonondrive.com>
   * version 1.1.1
		タイムラインが円形で、時刻盤が曜日表示の FLASH を追加
		ログファイルが存在しない時にエラーが出る不具合を修正
2004.04.28 phonondrive  <tdiary@phonondrive.com>
   * version 1.1.0
		タイムラインが円形の FLASH を追加
2004.04.27 phonondrive  <tdiary@phonondrive.com>
   * version 1.0.1
		時刻目盛テキストの色が変更されない不具合を修正
2004.04.25 phonondrive  <tdiary@phonondrive.com>
   * version 1.0.0
=end


# --------------------------------------------------------------------
# プラグインの動作
# --------------------------------------------------------------------

def tdiarytimes_flashstyle
	if @conf['tdiarytimes_f.templete'] == nil or @conf['tdiarytimes_f.templete'] == ""
		r = %Q|使用を開始するには、<a href="./#{@update}?conf=tdiarytimes_f">プリファレンス画面</a>にて一度設定を完了して下さい。(tdiarytimes-flashstyle)|
	else
		logname = ((@conf['tdiarytimes_f.log_path'] != "" and @conf['tdiarytimes_f.log_path'] != nil) ? @conf['tdiarytimes_f.log_path'] : "tdiarytimes.log")
		r = @conf['tdiarytimes_f.templete'].gsub(/\&uid/,"\&uid=#{File.mtime(logname.untaint).to_i}")
	end
end

# --------------------------------------------------------------------
# 日記登録時の処理
# --------------------------------------------------------------------

if /^(append|replace)$/ =~ @mode and @cgi.params['hide'][0] != 'true' then

	logname = ((@conf['tdiarytimes_f.log_path'] != "" and @conf['tdiarytimes_f.log_path'] != nil) ? @conf['tdiarytimes_f.log_path'] : "tdiarytimes.log")
	entr_lifetime = ((@conf['tdiarytimes_f.entr_lifetime'] != "" and @conf['tdiarytimes_f.entr_lifetime'] != nil) ? @conf['tdiarytimes_f.entr_lifetime'].to_i * 60 * 60 * 24 : 30 * 24 * 60 * 60)
	entr_interval = ((@conf['tdiarytimes_f.entr_interval'] != "" and @conf['tdiarytimes_f.entr_interval'] != nil) ? @conf['tdiarytimes_f.entr_interval'] : 2 * 60 * 60)

	begin
		logs = open(logname){|io| io.read }.chomp.split(',')
	rescue
		logs = ""
	end

	if (Time.now.to_i - logs.max.to_i) > entr_interval.to_i
		logs << "#{Time.now.to_i}"
		open(logname,"w"){|io|
			io.write(logs.find_all{|item| (Time.now.to_i - item.to_i) < entr_lifetime.to_i }.join(','))
		}
	end

end

# --------------------------------------------------------------------
# プリファレンス画面での設定
# --------------------------------------------------------------------

add_conf_proc( 'tdiarytimes_f', 'tdiarytimes-flashstyle の設定' ) do

	if @mode == 'saveconf' then

		filename = "tdiarytimes234x30.swf"
		width = "234"
		height = "30"
		argvs = ""

		argv = Array.new

		@conf['tdiarytimes_f.uid'] = @cgi.params['uid'][0]
		argv << "#{Time.now.to_i}&uid" if @conf['tdiarytimes_f.uid'] == "1"

		@conf['tdiarytimes_f.type'] = @cgi.params['type'][0]
		@conf['tdiarytimes_f.filename'] = @cgi.params['filename'][0]
		@conf['tdiarytimes_f.width'] = @cgi.params['width'][0]
		@conf['tdiarytimes_f.height'] = @cgi.params['height'][0]

		@conf['tdiarytimes_f.log_path'] = @cgi.params['log_path'][0]
		argv << "log_path=#{@cgi.params['log_path'][0]}" if @cgi.params['log_path'][0] != ""

		@conf['tdiarytimes_f.text_visible'] = @cgi.params['text_visible'][0]
		argv << "text_visible=#{@cgi.params['text_visible'][0]}" if @cgi.params['text_visible'][0] == "0"
		@conf['tdiarytimes_f.text_text'] = @cgi.params['text_text'][0]
		argv << "text_text=#{CGI::escape @cgi.params['text_text'][0].upcase}" if @cgi.params['text_text'][0] != ""
		@conf['tdiarytimes_f.text_rgb'] = @cgi.params['text_rgb'][0]
		argv << "text_rgb=0x#{@cgi.params['text_rgb'][0]}" if @cgi.params['text_rgb'][0] != ""

		@conf['tdiarytimes_f.face_visible'] = @cgi.params['face_visible'][0]
		argv << "face_visible=#{@cgi.params['face_visible'][0]}" if @cgi.params['face_visible'][0] == "0"
		@conf['tdiarytimes_f.face_rgb'] = @cgi.params['face_rgb'][0]
		argv << "face_rgb=0x#{@cgi.params['face_rgb'][0]}" if @cgi.params['face_rgb'][0] != ""

		@conf['tdiarytimes_f.stage_rgb'] = @cgi.params['stage_rgb'][0]
		argv << "stage_rgb=0x#{@cgi.params['stage_rgb'][0]}" if @cgi.params['stage_rgb'][0] != ""
		@conf['tdiarytimes_f.stage_alpha'] = @cgi.params['stage_alpha'][0]
		argv << "stage_alpha=#{@cgi.params['stage_alpha'][0]}" if @cgi.params['stage_alpha'][0] != ""
		@conf['tdiarytimes_f.bg_rgb'] = @cgi.params['bg_rgb'][0]
		argv << "bg_rgb=0x#{@cgi.params['bg_rgb'][0]}" if @cgi.params['bg_rgb'][0] != ""
		@conf['tdiarytimes_f.bg_alpha'] = @cgi.params['bg_alpha'][0]
		argv << "bg_alpha=#{@cgi.params['bg_alpha'][0]}" if @cgi.params['bg_alpha'][0] != ""
		@conf['tdiarytimes_f.bar_rgb'] = @cgi.params['bar_rgb'][0]
		argv << "bar_rgb=0x#{@cgi.params['bar_rgb'][0]}" if @cgi.params['bar_rgb'][0] != ""
		@conf['tdiarytimes_f.bar_width'] = @cgi.params['bar_width'][0]
		argv << "bar_width=#{@cgi.params['bar_width'][0]}" if @cgi.params['bar_width'][0] != ""

		@conf['tdiarytimes_f.entr_interval'] = @cgi.params['entr_interval'][0]
		@conf['tdiarytimes_f.entr_lifetime'] = @cgi.params['entr_lifetime'][0]
		@conf['tdiarytimes_f.fade_time'] = @cgi.params['fade_time'][0]
		argv << "fade_time=#{@cgi.params['fade_time'][0]}" if @cgi.params['fade_time'][0] != ""

		@conf['tdiarytimes_f.preview'] = @cgi.params['preview'][0]

		if @cgi.params['type'][0] == "0"
			filename = @cgi.params['filename'][0]
			width = @cgi.params['width'][0]
			height = @cgi.params['height'][0]
		elsif @cgi.params['type'][0]
			filename = "tdiarytimes#{@cgi.params['type'][0].gsub('-','')}.swf"
			width = @cgi.params['type'][0].split('-').first.split('x')[0]
			height = @cgi.params['type'][0].split('-').first.split('x')[1]
		end

		if argv.size > 0 then argvs = "?#{argv.join('&')}" end

		@conf['tdiarytimes_f.templete'] = tdiarytimes_flashstyle_templete(filename, argvs, width, height)
	end


	<<-HTML
		<h3 class="subtitle">設定の概要</h3>
		<p>() 内は初期値です。初期値を使用する場合は、空欄のままで構いません。色は RRGGBB 形式で指定して下さい。不透明度は 0 (透明) 〜 100 (不透明) です。線幅はピクセルで指定します。</p>
		<hr>
		<h3 class="subtitle">プレビュー</h3>
		#{tdiarytimes_flashstyle_preview}
		<hr>
		<h3 class="subtitle">表示する FLASH アプレットの選択</h3>
		<p><select name="type">
		<option value="0"#{if @conf['tdiarytimes_f.type'] == "0" then " selected" end}>プリセットを使用しない</option>
		<option value="125x30"#{if @conf['tdiarytimes_f.type'] == "125x30" then " selected" end}>tdiarytimes125x30.swf, 125x30</option>
		<option value="234x30"#{if @conf['tdiarytimes_f.type'] == "234x30" or @conf['tdiarytimes_f.type'] == nil or @conf['tdiarytimes_f.type'] == "" then " selected" end}>tdiarytimes234x30.swf, 234x30</option>
		<option value="468x30"#{if @conf['tdiarytimes_f.type'] == "468x30" then " selected" end}>tdiarytimes468x30.swf, 468x30</option>
		<option value="125x125-r"#{if @conf['tdiarytimes_f.type'] == "125x125-r" then " selected" end}>tdiarytimes125x125r.swf, 125x125 (円形)</option>
		<option value="125x125-r7"#{if @conf['tdiarytimes_f.type'] == "125x125-r7" then " selected" end}>tdiarytimes125x125r7.swf, 125x125 (円形, 曜日)</option>
		<option value="125x125-s"#{if @conf['tdiarytimes_f.type'] == "125x125-s" then " selected" end}>tdiarytimes125x125s.swf, 125x125 (曜日別)</option>
		</select></p>
		<h3 class="subtitle">プリセットを使用しない場合は、以下で指定して下さい。</h3>
		<p>FLASH のファイル名<br><input name="filename" value="#{@conf['tdiarytimes_f.filename'].to_s}" size="40"></p>
		<p>FLASH の表示幅<br><input name="width" value="#{@conf['tdiarytimes_f.width'].to_s}" size="20"></p>
		<p>FLASH の表示高さ<br><input name="height" value="#{@conf['tdiarytimes_f.height'].to_s}" size="20"></p>
		<hr>
		<h3 class="subtitle">タイトルテキスト</h3>
		<p>タイトルテキストの表示有無 (表示)<br><select name="text_visible">
		<option value="1"#{if @conf['tdiarytimes_f.text_visible'] != "0" then " selected" end}>表示</option>
		<option value="0"#{if @conf['tdiarytimes_f.text_visible'] == "0" then " selected" end}>非表示</option>
		</select></p>
		<p>タイトルテキスト (TDIARYTIMES-FLASHSTYLE)<br>使用出来る文字は、英大文字 (A-Z) と数字 (0-9)、および記号のみです。<br><input name="text_text" value="#{@conf['tdiarytimes_f.text_text'].to_s}" size="20"></p>
		<p>タイトルテキストの色 (333333)<br><input name="text_rgb" value="#{@conf['tdiarytimes_f.text_rgb'].to_s}" size="20"></p>
		<h3 class="subtitle">時刻目盛テキスト</h3>
		<p>時刻目盛テキストの表示有無 (表示)<br><select name="face_visible">
		<option value="1"#{if @conf['tdiarytimes_f.face_visible'] != "0" then " selected" end}>表示</option>
		<option value="0"#{if @conf['tdiarytimes_f.face_visible'] == "0" then " selected" end}>非表示</option>
		</select></p>
		<p>時刻目盛テキストの色 (333333)<br><input name="face_rgb" value="#{@conf['tdiarytimes_f.face_rgb'].to_s}" size="20"></p>
		<hr>
		<h3 class="subtitle">背景や棒グラフの色</h3>
		<p>背景の色 (FFFFFF)<br><input name="stage_rgb" value="#{@conf['tdiarytimes_f.stage_rgb'].to_s}" size="20"></p>
		<p>背景の不透明度 (0)<br><input name="stage_alpha" value="#{@conf['tdiarytimes_f.stage_alpha'].to_s}" size="20"></p>
		<p>タイムラインの背景の色 (333333)<br><input name="bg_rgb" value="#{@conf['tdiarytimes_f.bg_rgb'].to_s}" size="20"></p>
		<p>タイムラインの背景の不透明度 (100)<br><input name="bg_alpha" value="#{@conf['tdiarytimes_f.bg_alpha'].to_s}" size="20"></p>
		<p>タイムラインに記録される棒グラフの色 (EEEEEE)<br><input name="bar_rgb" value="#{@conf['tdiarytimes_f.bar_rgb'].to_s}" size="20"></p>
		<p>タイムラインに記録される棒グラフの線幅 (1)<br><input name="bar_width" value="#{@conf['tdiarytimes_f.bar_width'].to_s}" size="20"></p>
		<p>タイムラインに記録される棒グラフの寿命日数 (30)<br><input name="fade_time" value="#{@conf['tdiarytimes_f.fade_time'].to_s}" size="20"></p>
		<hr>
		<h3 class="subtitle">ログ管理</h3>
		<p>前回の日記登録から設定時間内はエントリを新規登録しない (2)<br><input name="entr_interval" value="#{@conf['tdiarytimes_f.entr_interval'].to_s}" size="20"></p>
		<p>設定日数後にログファイルからエントリを削除する (30)<br><input name="entr_lifetime" value="#{@conf['tdiarytimes_f.entr_lifetime'].to_s}" size="20"></p>
		<p>本プラグインが作成するログファイル名 (tdiarytimes.log)<br><input name="log_path" value="#{@conf['tdiarytimes_f.log_path'].to_s}" size="20"></p>
		<hr>
		<h3 class="subtitle">ユニークID を使用したファイル取得</h3>
		<p>ファイル取得のリクエストにユニークID (例えば ?#{Time.now.to_i}) を含めることにより、古いファイルがブラウザにキャッシュされたままになるのを防ぎます。FLASH のユニークID はプリファレンス設定時に、ログファイルのユニークID はエントリ登録時に更新されます。</p>
		<p>ユニークID の付加 (付加する)<br><select name="uid">
		<option value="1"#{if @conf['tdiarytimes_f.uid'] != "0" then " selected" end}>付加する</option>
		<option value="0"#{if @conf['tdiarytimes_f.uid'] == "0" then " selected" end}>付加しない</option>
		</select></p>
		<hr>
		<h3 class="subtitle">プレビュー</h3>
		<p>表示したい FLASH ファイル (.swf) が tdiary.rb と同じフォルダにアップロードされている必要があります。また、ログファイルが FLASH ファイルと同じフォルダに作成されていない場合にはグラフが表示されません。</p>
		<p>プレビュー (非表示)<br><select name="preview">
		<option value="0"#{if @conf['tdiarytimes_f.preview'] != "1" then " selected" end}>非表示</option>
		<option value="1"#{if @conf['tdiarytimes_f.preview'] == "1" then " selected" end}>表示</option>
		</select></p>
	HTML

end


def tdiarytimes_flashstyle_preview
	unless @conf.mobile_agent?
	<<-r
		<p>#{if @conf['tdiarytimes_f.preview'] == "1" then "#{tdiarytimes_flashstyle}" else "プレビュー表示を有効にすると、ここに FLASH が表示されます。" end}</p>
	r
	end
end

def tdiarytimes_flashstyle_templete( filename="tdiarytimes234x30.swf",  argvs="", width="234", height="30" )
	<<-r
		<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0" width="#{width}" height="#{height}" id="tdiarytimes" align="middle">
		<param name="allowScriptAccess" value="sameDomain" />
		<param name="movie" value="#{filename}#{argvs}" />
		<param name="play" value="false" />
		<param name="loop" value="false" />
		<param name="quality" value="high" />
		<param name="wmode" value="transparent" />
		<param name="bgcolor" value="#ffffff" />
		<embed src="#{filename}#{argvs}" play="false" loop="false" quality="high" wmode="transparent" bgcolor="#ffffff" width="#{width}" height="#{height}" name="tdiarytimes" align="middle" allowScriptAccess="sameDomain" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />
		</object>
	r
end
