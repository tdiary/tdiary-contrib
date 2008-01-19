# tdiarygraph_flashstyle.rb $Revision: 1.3 $
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
# counter.rb のカウンタログ (counter.log) をグラフ化した
# FLASH アプレットを表示します。
#
#
# Usage：
# --------------------------------------------------------------------
# プラグインは、プラグインフォルダに入れてください。
# tdiarygraph*.swf を tdiary.rb と同じフォルダにアップロードします。
# ヘッダ、フッタ部に記述した <%= tdiarygraph_flashstyle %> の部分に、
# FLASH アプレットが表示されます。
# counter.log は日記登録時に .swf と同じフォルダにコピーされます。
#
# ※ counter.rb を使用しており、かつカウンタログ (counter.log) の出力を
# オンにしている必要があります。 
#
#
# Options：
# --------------------------------------------------------------------
# グラフの色、透明度、サイズなどは、プリファレンス画面で設定できます。
#
#
# In secure mode：
# --------------------------------------------------------------------
# たぶん動作しません。
#
#
# Acknowledgements：
# --------------------------------------------------------------------
# counter.rb (counter.log)
#
# Copyright (c) 2002 MUTOH Masao <mutoh@highway.ne.jp>
# Distributed under the GPL2.
# http://ponx.s5.xrea.com/hiki/ja/counter.rb.html
#
#
=begin ChangeLog
2004.04.27 phonondrive  <tdiary@phonondrive.com>
   * version 1.3.0
		キャッシュ対策としてユニークIDを付加してファイル取得するオプションを追加
		対応 FLASH ファイルを e 系列に変更
		フォントを _sans から 04b03b に変更
			04b03b.ttf, copyright (c) 1998-2001 YUJI OSHIMOTO
			http://www.04.jp.org/
2004.04.10 phonondrive  <tdiary@phonondrive.com>
   * version 1.2.1
		レポート書式で改行タグが機能しない不具合を修正
		背景の枠線を表示しないオプションを追加
		対応 FLASH ファイルを d 系列に変更
2004.04.09 phonondrive  <tdiary@phonondrive.com>
   * version 1.2.0
		ログファイルが転送されない不具合を修正
		作成するログのデフォルト名を変更 (tdiarygraph.log → counter.log)
		線幅を絶対値で指定出来るオプションを追加
		レポート書式のカスタマイズオプションを追加
		対応 FLASH ファイルを c 系列に変更
2004.04.05 phonondrive  <tdiary@phonondrive.com>
   * version 1.1.1
		線の太さを変更するオプションを追加
		対応 FLASH ファイルに b 系列を追加
2004.04.05 phonondrive  <tdiary@phonondrive.com>
   * version 1.1.0
		Ruby 1.6.x に対応 (1.6.7 で動作確認)
		作成するログのデフォルト名を変更 (counter.log → tdiarygraph.log)
2004.04.04 phonondrive  <tdiary@phonondrive.com>
   * version 1.0.0
=end




# --------------------------------------------------------------------
# プラグインの表示
# --------------------------------------------------------------------

def tdiarygraph_flashstyle
	if @conf['tdiarygraph_f.templete'] == nil or @conf['tdiarygraph_f.templete'] == ""
		r = %Q|使用を開始するには、<a href="./#{h @update}?conf=tdiarygraph_f">プリファレンス画面</a>にて一度設定を完了して下さい。(tdiarygraph-flashstyle)|
	else
		logname = ((@conf['tdiarygraph_f.log_path'] != "" and @conf['tdiarygraph_f.log_path'] != nil) ? @conf['tdiarygraph_f.log_path'] : "counter.log")
		r = @conf['tdiarygraph_f.templete'].gsub(/\&uid/,"\&uid=#{File.mtime(logname.untaint).to_i}")
	end
end


# --------------------------------------------------------------------
# 日記登録時の処理 (counter.log のコピー)
# --------------------------------------------------------------------

if /^(append|replace)$/ =~ @mode and @cgi.params['hide'][0] != 'true' then
	logname = ((@conf['tdiarygraph_f.log_path'] != "" and @conf['tdiarygraph_f.log_path'] != nil) ? @conf['tdiarygraph_f.log_path'] : "counter.log")

	open("#{@cache_path}/counter/counter.log"){|input|
		open(logname, "w"){|output|
			output.write(input.read)
		}
	}
end


# --------------------------------------------------------------------
# プリファレンス画面での設定
# --------------------------------------------------------------------

add_conf_proc( 'tdiarygraph_f', 'tdiarygraph-flashstyle の設定' ) do

	if @mode == 'saveconf' then

		filename = "tdiarygraph468x60e.swf"
		width = "468"
		height = "60"
		argvs = ""

		argv = Array.new

		@conf['tdiarygraph_f.uid'] = @cgi.params['uid'][0]
		argv << "#{Time.now.to_i}&uid" if @conf['tdiarygraph_f.uid'] == "1"

		@conf['tdiarygraph_f.type'] = @cgi.params['type'][0]
		@conf['tdiarygraph_f.filename'] = @cgi.params['filename'][0]
		@conf['tdiarygraph_f.width'] = @cgi.params['width'][0]
		@conf['tdiarygraph_f.height'] = @cgi.params['height'][0]

		@conf['tdiarygraph_f.log_path'] = @cgi.params['log_path'][0]
		argv << "log_path=#{@cgi.params['log_path'][0]}" if @cgi.params['log_path'][0] != ""
		@conf['tdiarygraph_f.init_num'] = @cgi.params['init_num'][0]
		argv << "init_num=#{@cgi.params['init_num'][0]}" if @cgi.params['init_num'][0] != ""

		@conf['tdiarygraph_f.text_text'] = @cgi.params['text_text'][0].upcase
		argv << "text_text=#{h NKF::nkf('-s', @cgi.params['text_text'][0].upcase)}" if @cgi.params['text_text'][0] != ""
		@conf['tdiarygraph_f.text_rgb'] = @cgi.params['text_rgb'][0]
		argv << "text_rgb=0x#{@cgi.params['text_rgb'][0]}" if @cgi.params['text_rgb'][0] != ""
		@conf['tdiarygraph_f.text_report'] = @cgi.params['text_report'][0]
		argv << "text_report=#{@cgi.params['text_report'][0]}" if @cgi.params['text_report'][0] == "0"
		@conf['tdiarygraph_f.text_report_format'] = @cgi.params['text_report_format'][0]
		argv << "text_report_format=#{tdiarygraph_flashstyle_text_report_format(@cgi.params['text_report_format'][0])}" if @cgi.params['text_report_format'][0] != ""
		@conf['tdiarygraph_f.text_report_rgb'] = @cgi.params['text_report_rgb'][0]
		argv << "text_report_rgb=0x#{@cgi.params['text_report_rgb'][0]}" if @cgi.params['text_report_rgb'][0] != ""
		@conf['tdiarygraph_f.bg_rgb'] = @cgi.params['bg_rgb'][0]
		argv << "bg_rgb=0x#{@cgi.params['bg_rgb'][0]}" if @cgi.params['bg_rgb'][0] != ""
		@conf['tdiarygraph_f.bg_alpha'] = @cgi.params['bg_alpha'][0]
		argv << "bg_alpha=#{@cgi.params['bg_alpha'][0]}" if @cgi.params['bg_alpha'][0] != ""
		@conf['tdiarygraph_f.bg_frame'] = @cgi.params['bg_frame'][0]
		argv << "bg_frame=#{@cgi.params['bg_frame'][0]}" if @cgi.params['bg_frame'][0] == "1"
		@conf['tdiarygraph_f.bar_rgb'] = @cgi.params['bar_rgb'][0]
		argv << "bar_rgb=0x#{@cgi.params['bar_rgb'][0]}" if @cgi.params['bar_rgb'][0] != ""
		@conf['tdiarygraph_f.bar_alpha'] = @cgi.params['bar_alpha'][0]
		argv << "bar_alpha=#{@cgi.params['bar_alpha'][0]}" if @cgi.params['bar_alpha'][0] != ""
		@conf['tdiarygraph_f.line_rgb'] = @cgi.params['line_rgb'][0]
		argv << "line_rgb=0x#{@cgi.params['line_rgb'][0]}" if @cgi.params['line_rgb'][0] != ""
		@conf['tdiarygraph_f.line_alpha'] = @cgi.params['line_alpha'][0]
		argv << "line_alpha=#{@cgi.params['line_alpha'][0]}" if @cgi.params['line_alpha'][0] != ""

		@conf['tdiarygraph_f.bar_width'] = @cgi.params['bar_width'][0]
		argv << "bar_width=#{@cgi.params['bar_width'][0]}" if @cgi.params['bar_width'][0] != ""
		@conf['tdiarygraph_f.line_width'] = @cgi.params['line_width'][0]
		argv << "line_width=#{@cgi.params['line_width'][0]}" if @cgi.params['line_width'][0] != ""

		@conf['tdiarygraph_f.bold'] = @cgi.params['bold'][0]
		argv << "bold=#{@cgi.params['bold'][0]}" if @cgi.params['bold'][0] != ""

		@conf['tdiarygraph_f.preview'] = @cgi.params['preview'][0]

		if @cgi.params['type'][0] == "0"
			filename = @cgi.params['filename'][0]
			width = @cgi.params['width'][0]
			height = @cgi.params['height'][0]
		elsif @cgi.params['type'][0]
			filename = "tdiarygraph#{@cgi.params['type'][0].gsub('-','')}.swf"
			width = @cgi.params['type'][0].split('-').first.split('x')[0]
			height = @cgi.params['type'][0].split('-').first.split('x')[1]
		end

		if argv.size > 0 then argvs = "?#{argv.join('&')}" end

		@conf['tdiarygraph_f.templete'] = tdiarygraph_flashstyle_templete(filename, argvs, width, height)
	end


	<<-HTML
		<h3 class="subtitle">設定の概要</h3>
		<p>() 内は初期値です。初期値を使用する場合は、空欄のままで構いません。色は RRGGBB 形式で指定して下さい。不透明度は 0 (透明) 〜 100 (不透明) です。線幅はピクセルで指定します。</p>
		<hr>
		<h3 class="subtitle">プレビュー</h3>
		#{tdiarygraph_flashstyle_preview}
		<hr>
		<h3 class="subtitle">表示する FLASH アプレットの選択</h3>
		<p><select name="type">
		<option value="0"#{" selected" if @conf['tdiarygraph_f.type'] == "0"}>プリセットを使用しない</option>
		<option value="468x60-e"#{" selected" if @conf['tdiarygraph_f.type'] == "468x60-e" or @conf['tdiarygraph_f.type'] == nil or @conf['tdiarygraph_f.type'] == ""}>tdiarygraph468x60e.swf, 468x60</option>
		<option value="728x90-e"#{" selected" if @conf['tdiarygraph_f.type'] == "728x90-e"}>tdiarygraph728x90e.swf, 728x90</option>
		<option value="125x125-e"#{" selected" if @conf['tdiarygraph_f.type'] == "125x125-e"}>tdiarygraph125x125e.swf, 125x125</option>
		<option value="240x180-e"#{" selected" if @conf['tdiarygraph_f.type'] == "240x180-e"}>tdiarygraph240x180e.swf, 240x180</option>
		<option value="120x90-e"#{" selected" if @conf['tdiarygraph_f.type'] == "120x90-e"}>tdiarygraph120x90e.swf, 120x90</option>
		</select></p>
		<h3 class="subtitle">プリセットを使用しない場合は、以下で指定して下さい。</h3>
		<p>FLASH のファイル名<br><input name="filename" value="#{h @conf['tdiarygraph_f.filename']}" size="40"></p>
		<p>FLASH の表示幅<br><input name="width" value="#{h @conf['tdiarygraph_f.width']}" size="20"></p>
		<p>FLASH の表示高さ<br><input name="height" value="#{h @conf['tdiarygraph_f.height']}" size="20"></p>
		<hr>
		<h3 class="subtitle">アクセスログデータ</h3>
		<p>本プラグインが作成する counter.log の複製のファイル名 (counter.log)<br><input name="log_path" value="#{h @conf['tdiarygraph_f.log_path']}" size="20"></p>
		<p>累計アクセス数の初期値。(0) counter.rb で init_num を指定している場合は、同じ値 (#{@conf['counter.init_num']}) を設定してください。<br><input name="init_num" value="#{h @conf['tdiarygraph_f.init_num']}" size="20"></p>
		<hr>
		<h3 class="subtitle">タイトルテキスト</h3>
		<p>タイトルテキスト (TDIARYGRAPH-FLASHSTYLE)<br>使用出来る文字は、英大文字 (A-Z) と数字 (0-9)、および記号のみです。<br><input name="text_text" value="#{h @conf['tdiarygraph_f.text_text']}" size="20"></p>
		<p>タイトルテキストの色 (FFFFFF)<br><input name="text_rgb" value="#{h @conf['tdiarygraph_f.text_rgb']}" size="20"></p>
		<h3 class="subtitle">レポートテキスト</h3>
		<p>レポートの表示有無 (表示)<br><select name="text_report">
		<option value="1"#{" selected" if @conf['tdiarygraph_f.text_report'] != "0"}>表示</option>
		<option value="0"#{" selected" if @conf['tdiarygraph_f.text_report'] == "0"}>非表示</option>
		</select></p>
		<p>レポートテキストの色 (CCCCCC)<br><input name="text_report_rgb" value="#{h @conf['tdiarygraph_f.text_report_rgb']}" size="20"></p>
		<h3 class="subtitle">レポート書式のカスタマイズ</h3>
		<p>タグを埋め込んだ位置にデータが展開されます。<br>使用出来る文字 (タグを除く) は、英大文字 (A-Z) と数字 (0-9)、および記号のみです。<br><input name="text_report_format" value="#{h @conf['tdiarygraph_f.text_report_format']}" size="70"></p>
		<p>[ 使用出来るタグ ] &lt;firstday&gt; : ログ初日, &lt;lastday&gt; : ログ最終日, &lt;days&gt; : ログ日数, &lt;total&gt; : 累計アクセス数, &lt;peak&gt; : 日別最大アクセス数, &lt;br&gt; : 改行</p>
		<hr>
		<h3 class="subtitle">背景や棒グラフの色</h3>
		<p>背景の色 (333333)<br><input name="bg_rgb" value="#{h @conf['tdiarygraph_f.bg_rgb']}" size="20"></p>
		<p>背景の不透明度 (100)<br><input name="bg_alpha" value="#{h @conf['tdiarygraph_f.bg_alpha']}" size="20"></p>
		<p>背景の枠線 (非表示)<br><select name="bg_frame">
		<option value="0"#{" selected" if @conf['tdiarygraph_f.bg_frame'] == "0" or @conf['tdiarygraph_f.bg_frame'] == nil or @conf['tdiarygraph_f.bg_frame'] == ""}>非表示</option>
		<option value="1"#{" selected" if @conf['tdiarygraph_f.bg_frame'] == "1"}>左と上に表示</option>
		</select></p>
		<p>日別アクセス数棒グラフの色 (CCCCCC)<br><input name="bar_rgb" value="#{h @conf['tdiarygraph_f.bar_rgb']}" size="20"></p>
		<p>日別アクセス数棒グラフの不透明度 (100)<br><input name="bar_alpha" value="#{h @conf['tdiarygraph_f.bar_alpha']}" size="20"></p>
		<p>累計アクセス数棒グラフの色 (666666)<br><input name="line_rgb" value="#{h @conf['tdiarygraph_f.line_rgb']}" size="20"></p>
		<p>累計アクセス数棒グラフの不透明度 (100)<br><input name="line_alpha" value="#{h @conf['tdiarygraph_f.line_alpha']}" size="20"></p>
		<hr>
		<h3 class="subtitle">棒グラフの線幅</h3>
		<p>日別アクセス数棒グラフの線幅を絶対値で指定します。<br><input name="bar_width" value="#{h @conf['tdiarygraph_f.bar_width']}" size="20"></p>
		<p>累計アクセス数棒グラフの線幅を絶対値で指定します。<br><input name="line_width" value="#{h @conf['tdiarygraph_f.line_width']}" size="20"></p>
		<hr>
		<h3 class="subtitle">モアレ対策</h3>
		<p>棒グラフの線幅を相対的に微調整します。(0) 設定した値に対して線幅がリニアに変更されるわけではありません。<br><br><input name="bold" value="#{h @conf['tdiarygraph_f.bold']}" size="20"></p>
		<hr>
		<h3 class="subtitle">ユニークID を使用したファイル取得</h3>
		<p>ファイル取得のリクエストにユニークID (例えば ?#{Time.now.to_i}) を含めることにより、古いファイルがブラウザにキャッシュされたままになるのを防ぎます。FLASH のユニークID はプリファレンス設定時に、ログファイルのユニークID はエントリ登録時に更新されます。</p>
		<p>ユニークID の付加 (付加する)<br><select name="uid">
		<option value="1"#{" selected" if @conf['tdiarygraph_f.uid'] != "0"}>付加する</option>
		<option value="0"#{" selected" if @conf['tdiarygraph_f.uid'] == "0"}>付加しない</option>
		</select></p>
		<hr>
		<h3 class="subtitle">プレビュー</h3>
		<p>表示したい FLASH ファイル (.swf) が tdiary.rb と同じフォルダにアップロードされている必要があります。また、カウンタログファイルが FLASH ファイルと同じフォルダに転送されていない場合にはグラフが表示されません。</p>
		<p>プレビュー (非表示)<br><select name="preview">
		<option value="0"#{" selected" if @conf['tdiarygraph_f.preview'] != "1"}>非表示</option>
		<option value="1"#{" selected" if @conf['tdiarygraph_f.preview'] == "1"}>表示</option>
		</select></p>
	HTML

end


def tdiarygraph_flashstyle_preview
	unless @conf.mobile_agent?
	<<-r
		<p>#{if @conf['tdiarygraph_f.preview'] == "1" then "#{tdiarygraph_flashstyle}" else "プレビュー表示を有効にすると、ここに FLASH が表示されます。" end}</p>
	r
	end
end


def tdiarygraph_flashstyle_templete( filename="tdiarygraph468x60e.swf",  argvs="", width="468", height="60" )
	<<-r
		<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0" width="#{h width}" height="#{h height}" id="tdiarygraph" align="middle">
		<param name="allowScriptAccess" value="sameDomain" />
		<param name="movie" value="#{h filename}#{h argvs}" />
		<param name="play" value="false" />
		<param name="loop" value="false" />
		<param name="quality" value="high" />
		<param name="wmode" value="transparent" />
		<param name="bgcolor" value="#ffffff" />
		<embed src="#{h filename}#{h argvs}" play="false" loop="false" quality="high" wmode="transparent" bgcolor="#ffffff" width="#{h width}" height="#{h height}" name="tdiarygraph" align="middle" allowScriptAccess="sameDomain" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />
		</object>
	r
end


def tdiarygraph_flashstyle_text_report_format( format="" )
	if format != ""
		r = format.gsub('<', '&lt;').gsub('>', '&gt;').gsub(' ', '+')
	end
end
