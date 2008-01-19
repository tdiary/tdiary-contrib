# tdiarytimes_textstyle.rb $Revision: 1.3 $
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
# 日記を登録した時間帯をタイムライン上に記録します。
# 記録されたエントリは日時の経過と共にフェードアウトしていきます。
# このような MTBlogTimes や tdiarytimes と同等の機能をテキストで実現します。
# また、テキストベースであることを生かした柔軟なサイトデザインが可能です。
# ruby-gd のインストール作業も必要ないため、すぐに使用出来ます。
#
#
# Usage：
# --------------------------------------------------------------------
# プラグインは、プラグインフォルダに入れてください。
# ヘッダ、あるいはフッタ部に入力した <%= tdiarytimes_textstyle %>
# の位置にタイムライン文字列が展開されます。
# 新しいエントリの記録や保持期間の過ぎた古いエントリの削除は、
# 日記の追加および登録時に行われます。
# ただし、エントリのフェードアウト効果はリアルタイムに計算されます。
# エントリの表示分解能は10分ごとです。
#
#
# Options：
# --------------------------------------------------------------------
#
# 現在、次の9つのオプションが用意されています。
#
# init_text	日記の登録されていない時間帯の文字列 (任意の文字列)
# entr_text	日記が登録された時間帯の文字列 (任意の文字列)
# init_color	日記の登録されていない時間帯の文字列の色 (RRBBGG形式で指定)
# entr_color	日記が登録された時間帯の文字列の色 (RRBBGG形式で指定)
# fade_color	日記が登録された時間帯の文字列のフェードアウト先の色 (RRBBGG形式で指定)
# init_css	タイムライン文字列全体のCSS設定 (CSSの書式に準拠)
# entr_css	日記が登録された時間帯の文字列のCSS設定 (CSSの書式に準拠)
# title_text	オブジェクト上にマウスをポイントした時のTIPS文字列 (任意の文字列)
# fade_time	ログとして保存しておく(フェードアウトに要する)日数 (任意の数値)
# entr_interval	前回のエントリ登録から指定時間以内は新規登録しない (任意の数値)
#
# オプション値の設定方法には3つの方法があり、その優先順位は次の通りです。
# <%= tdiarytimes_textstyle %> 引数指定 ＞ tdiary.conf設定値 ＞ デフォルト値
# 
# entr_intervalを除いた全てのオプション値は <%= %> への引数指定により設定出来るため、
# ページにごとに意匠を変更するなど自由度の高いサイトデザインが可能です。
# 一方で、全てのオプションにデフォルト値が用意されているため、
# 全く設定を行わなくても動作します。
# デフォルト値の具体的な値については、tdiary.confへの記述方法の項を参照して下さい。
#
#
# <%= tdiarytimes_textstyle %>への引数指定によるオプション設定方法
# --------------------------------------------------------------------
#【書式】
# <%= tdiarytimes_textstyle init_text, entr_text, init_color, entr_color, fade_color, init_css, entr_css, title_text, fade_time %>
#
#【記述例】 
# <%=tdiarytimes_textstyle "●","●","004400","66ff66","004400","background-color:#002200;font-size:9px",nil,"TEXTSTYLE!!",15 %>
#
# ※ tdiary.conf指定値、またはデフォルト値を使用したい場合は、引数に nil を指定してください。
#
#
# tdiary.confへの記述によるオプション設定方法
# --------------------------------------------------------------------
#【記述例】 (例として指定されている値は、プラグイン本体の持つデフォルト値です)
# @options['tdiarytimes_textstyle.init_text'] = "|"
# @options['tdiarytimes_textstyle.entr_text'] = "|"
# @options['tdiarytimes_textstyle.init_color'] = "444444"
# @options['tdiarytimes_textstyle.entr_color'] = "eeeeee"
# @options['tdiarytimes_textstyle.fade_color'] = "444444"
# @options['tdiarytimes_textstyle.init_css'] = "background-color:#444444;"
# @options['tdiarytimes_textstyle.entr_css'] = ""
# @options['tdiarytimes_textstyle.title_text'] = "TDIARYTIMES-TEXTSTYLE"
# @options['tdiarytimes_textstyle.fade_time'] = 30
# @options['tdiarytimes_textstyle.entr_interval'] = 1
#
# ※ fade_time の単位は日、entr_interval の単位は時間です。
# ※ ログとして保存しておく期間(フェードアウト期間)を過ぎたデータエントリは、
# 指定期間経過後の次回日記追加時にログファイルから削除されます。
# この期間を決定する fade_time 値は、<%= %> 引数からは指定出来ません。
# デフォルト値(30日)以外の値を用いたい場合は、必ず tdiary.conf にて指定して下さい。
# 同様に、entr_interval もデフォルト値(1時間)以外に設定したい場合は、
# tdiary.conf にて指定して下さい。ちなみに0.5だと30分間隔になります。
#
#
# In secure mode：
# --------------------------------------------------------------------
# 現在のところ動作しません。(ログファイルを読み込めない為)
#
#
# Acknowledgements：
# --------------------------------------------------------------------
# This plugin is based on tdiarytimes.rb $Revision: 1.3 $
# Copyright (c) 2003 neuichi <neuichi@nmnl.jp>
# Distributed under the GPL
# http://nmnl.jp/hiki/software/?tDiary+%3A%3A+Plugin
#
#
=begin ChangeLog
2004.03.04 phonondrive  <tdiary@phonondrive.com>
   * version 1.0.4
	非応答USER-AGENTリストを更新しました。

2004.02.05 phonondrive  <tdiary@phonondrive.com>
   * version 1.0.3
	フェードアウト効果の計算結果が正しく出力されない点を修正しました。

2004.01.30 phonondrive  <tdiary@phonondrive.com>
   * version 1.0.2
	最低登録間隔のオプション (entr_interval) を追加。
	前回のエントリ登録から指定時間以内は新規登録しないようにしました。

2004.01.29 phonondrive  <tdiary@phonondrive.com>
   * version 1.0.1
	replace(登録)時もエントリを記録するようにしました。
	次のUSER-AGENTからの呼び出しには結果を出力しないようにしました。
		モバイル端末 (tDiary準拠)
		テキストブラウザ (w3m, Lynx, links)
		CSS非対応ブラウザ (Mosaic, Lite, iCab, JustView, WebExplorer)
		検索ボット (bot, crawler, Spider, Slurp, inktomi, Sidewinder, naver)
		その他 (libwww, antenna)

2004.01.28 phonondrive  <tdiary@phonondrive.com>
   * version 1.0.0
=end




# tDiarytimes_textstyle の結果を出力しない USER-AGENT リスト
# モバイル端末、テキストブラウザ、CSS非対応ブラウザ、検索ボット、アンテナなど
# 大文字・小文字は区別しません。

def tdiarytimes_textstyle_ignore_user_agent; "w3m|Lynx|links|Mosaic|Lite|iCab|JustView|WebExplorer|bot|crawler|Spider|Slurp|inktomi|Sidewinder|naver|libwww|archiver|http|check|WDB|WWWC|WWWD|samidare|tamatebako|NATSU-MICAN|hina|antenna"; end




# --------------------------------------------------------------------
# 日記登録時の処理
# --------------------------------------------------------------------

if /^(append|replace)$/ =~ @mode then

	# オプション値(エントリ保持期間)の読み込みと設定

	fade_time = @options['tdiarytimes_textstyle.fade_time'] || 30
	fade_time = 24 * 60 * 60 * fade_time.to_f

	entr_interval = @options['tdiarytimes_textstyle.entr_interval'] || 1
	entr_interval = 60 * 60 * entr_interval.to_f


	# ログデータの読み込み

	cache = "#{@cache_path}/tdiarytimes_textstyle"
	Dir::mkdir( cache ) unless File::directory?( cache )

	begin
		io = open("#{cache}/tdiarytimes_textstyle.dat","r")
		ary_data =  Marshal.load(io)
		io.close

		# 1.0.1 >> 1.0.2 ログデータ移行用
		if ary_data.size == 144
			ary_data.push(Time.now.to_i - entr_interval - 1)
		end

	rescue
		# ログがない場合は仮データを用意
		ary_data = Array.new(145) {|i| 0 }
	end


	# 不良データや寿命が来たエントリを削除する

	(0..143).each {|i|
		delta = (Time.now.to_i - ary_data[i])/fade_time.to_f
		if delta < 0 || delta > 1
			ary_data[i] = 0
		end
	}


	# 最低登録間隔を経過していたら、日記が登録された時間帯に新しいエントリをセットする

	if (Time.now.to_i - ary_data[144]) > entr_interval.to_f
		ary_data[(Time.now.strftime('%H').to_i*6 + Time.now.strftime('%M').to_f/10).to_i] = Time.now.to_i
		# 最終登録時間の記録
		ary_data[144] = Time.now.to_i 
	end


	# ログデータの書き込み

	io = open("#{cache}/tdiarytimes_textstyle.dat","w")
		Marshal.dump(ary_data,io)
	io.close
end




# --------------------------------------------------------------------
# プラグイン表示時の動作
# --------------------------------------------------------------------

def tdiarytimes_textstyle(init_text = nil, entr_text = nil, init_color = nil, entr_color = nil, fade_color = nil, init_css = nil, entr_css = nil, title_text = nil, fade_time = nil)


    # モバイル端末、テキストブラウザ、CSS非対応ブラウザ、検索ボットなどには結果を出力しない

    unless @cgi.mobile_agent? || @cgi.user_agent =~ %r[(#{tdiarytimes_textstyle_ignore_user_agent})]i


	r = ""


	# オプション値の読み込みと設定

	init_text = @options['tdiarytimes_textstyle.init_text'] || "|" unless init_text
	entr_text = @options['tdiarytimes_textstyle.entr_text'] || "|" unless entr_text
	init_color = @options['tdiarytimes_textstyle.init_color'] || "444444" unless init_color
	entr_color = @options['tdiarytimes_textstyle.entr_color'] || "eeeeee" unless entr_color
	fade_color = @options['tdiarytimes_textstyle.fade_color'] || "444444" unless fade_color
	init_css = @options['tdiarytimes_textstyle.init_css'] || "background-color:#444444;" unless init_css
	entr_css = @options['tdiarytimes_textstyle.entr_css'] || "" unless entr_css
	title_text = @options['tdiarytimes_textstyle.title_text'] || "TDIARYTIMES-TEXTSTYLE" unless title_text
	fade_time = @options['tdiarytimes_textstyle.fade_time'] || 30 unless fade_time


	entr_color_rgb = entr_color.unpack("a2a2a2")
	fade_color_rgb = fade_color.unpack("a2a2a2")

	fade_time = 24 * 60 * 60 * fade_time.to_f


	# ログデータの読み込み

	cache = "#{@cache_path}/tdiarytimes_textstyle"

	begin
		io = open("#{cache}/tdiarytimes_textstyle.dat","r")
		ary_data =  Marshal.load(io)
		io.close
	rescue
		# ログファイルが見つからない場合はエラーとダミーデータを表示
		r << %Q|Error! cannot open log file.|
		ary_data = Array.new(145) {|i| 0 }
	end


	# htmlデータの出力

	r << %Q|<span style="color:##{h init_color};#{h init_css}" title="#{h title_text}">|

	(0..143).each {|i|
		data = ary_data[i]
		if data != 0
			delta = (Time.now.to_i - data)/fade_time.to_f
			if  delta < 0
				# 不良エントリ対策
				now_color = init_color
			elsif delta > 1
				# フェードアウト期間超過エントリ対策
				now_color = fade_color
			else
				# 正常なエントリの処理
				now_color = ""
				(0..2).each{|i|
					now_color << format("%02x", entr_color_rgb[i].hex + ((fade_color_rgb[i].hex - entr_color_rgb[i].hex)*delta).to_i)
				}
			end
			r << %Q|<span style="color:##{h now_color};#{h entr_css}" title="#{Time.at(data).strftime('%b %d,%Y')}">#{entr_text}</span>|
		else
			r << %Q|#{init_text}|
		end
	}

	r << %Q|</span>|

    end

end
