# tdiarytimes.rb $Revision: 1.2 $
#
# Copyright (c) 2003 neuichi <neuichi@nmnl.jp>
# Distributed under the GPL
#
# プラグイン配布ページ
# http://nmnl.jp/hiki/software/?tDiary+%3A%3A+Plugin
#
# 動作条件:
# ruby-gdが使える環境が必要です。
#
# 使い方:
# このプラグインをプラグインディレクトリに入れ、
# index.rbと同じディレクトリに、tdiarytimes.pngという名前の
# サーバが書き込み権限を持っているファイルを作ります。
#	これで日記に書き込みするごとに、tdiarytimes.pngに
#	画像を書き込みます。
# 
# 日記上からこのpngファイルを呼び出すには、
# tDiray上からプラグインとして
# <%=tdiarytimes%>
# として呼び出します。
# 引数としてimgタグのaltの文字列を指定することも出来ます。
# <%=tdiarytimes '文字列'%>
#
# また、tdiary.confに以下のオプションを書き込むことにより、
# カスタマイズをすることが出来ます。
# 
# @options['tdiarytimes.width'] = 400
# 四角の横幅。デフォルト値400。
# 実際に出力される画像サイズは、これに+10したサイズ。
# 
# @options['tdiarytimes.height'] = 20
# 四角の縦幅。デフォルト値20。
# 実際に出力される画像サイズは、これに+16したサイズ。
# 
# @options['tdiarytimes.file'] = 'tdiarytimes.png'
# 出力する画像ファイル名。デフォルトは'tdiarytimes.png'
# 
# @options['tdiarytimes.fillcolor'] = '#444444'
# 四角の色。デフォルトは'#444444'
# 
# @options['tdiarytimes.linecolor'] = '#ffffff'
# 縦棒の色。デフォルトは'#ffffff'
# 
# @options['tdiarytimes.textcolor'] = '#444444'
# 文字色。デフォルトは'#444444'
# 
# @options['tdiarytimes.text'] = 'T D I A R Y T I M E S'
# 出力する文字。デフォルトは'T D I A R Y T I M E S'。なお半角英数字のみ対応。
# 
# @options['tdiarytimes.day'] = 30
# ログを保存する最大日数。デフォルトは30。
# この場合、30日以上経ったデータは消去され、縦棒として描画されなくなる。
#

require 'GD'

if /^(append|replace)$/ =~ @mode then

	#初期設定
	width = @options['tdiarytimes.width'] || 400
	height = @options['tdiarytimes.height'] || 20
	file = @options['tdiarytimes.file'] || 'tdiarytimes.png'
	fillcolor = @options['tdiarytimes.fillcolor'] || '#444444'
	linecolor = @options['tdiarytimes.linecolor'] || '#ffffff'
	textcolor = @options['tdiarytimes.textcolor'] || '#444444'
	text = @options['tdiarytimes.text'] || 'T D I A R Y T I M E S'
	day = @options['tdiarytimes.day'] || 30 
	
	cache = "#{@cache_path}/tdiarytimes"
	Dir::mkdir( cache ) unless File::directory?( cache )

	image = GD::Image.new(width + 10,height + 16)
	transcolor = image.colorAllocate("#fffffe")
	image.transparent(transcolor)
	image.interlace = TRUE
	fillcolor = image.colorAllocate(fillcolor)
	linecolor = image.colorAllocate(linecolor)
	textcolor = image.colorAllocate(textcolor)
	
	#帯の描画
	image.filledRectangle(5,8,width + 4,height + 7,fillcolor)

	#時間挿入
	if width >= 160
		hour = 2
		hour_w = width / 12.0
		image.string(GD::Font::TinyFont, 2, height + 8, "0", textcolor)
		11.times {
			image.string(GD::Font::TinyFont, (hour_w * hour/2).to_i , height + 8, hour.to_s, textcolor)
			hour += 2
		}
		image.string(GD::Font::TinyFont, width + 2, height + 8, "0", textcolor)
	else
		hour = 0
		hour_w = width / 6.0
		6.times {
			image.string(GD::Font::TinyFont, (hour_w * hour/4).to_i + 4, height + 8, hour.to_s, textcolor)
			hour += 4
		}
		image.string(GD::Font::TinyFont, width + 2, height + 8, "0", textcolor)
	end

	#現在時刻の保存,読み込み
	begin
		io = open("#{cache}/tdiarytimes.dat","r")
	    ary_times =  Marshal.load(io)
	  io.close
	rescue
		ary_times = []
	end

	ary_times << Time.now.to_f
	ary_times_new = []

	while ary_times.size != 0
		time = ary_times.shift
		time_now = Time.now.to_f.to_i
		ary_times_new << time.to_i if (86400 * day) > (time_now - time).to_i
	end

	ary_times = ary_times_new

	io = open("#{cache}/tdiarytimes.dat","w")
	  Marshal.dump(ary_times,io)
	io.close


	#時間軸の挿入
	while ary_times.size != 0
		time = Time.at(ary_times.shift)
		time_w = ((time.to_a[2] * 60 + time.to_a[1]) / 1440.0 * width).to_i
		image.line(time_w + 5, 8 ,time_w + 5,height + 7, linecolor)
	end

	#文字の挿入
	image.string(GD::Font::TinyFont, 5, 0, text, textcolor)

	pngfile = open(file, 'w')
		image.png(pngfile)
	pngfile.close
	
end

def tdiarytimes(alt = nil)
	width = @options['tdiarytimes.width'].to_i || 400
	width += 10
	
	height = @options['tdiarytimes.height'].to_i || 20
	height += 16
	
	file = @options['tdiarytimes.file'] || 'tdiarytimes.png'
	text = @options['tdiarytimes.text'] || 'T D I A R Y T I M E S'

	result = ""
	
	if alt
		result << %Q|<img src="#{h file}" alt="#{h alt}" width="#{width}" height="#{height}" class="tdiarytimes">|
	else
		result << %Q|<img src="#{h file}" alt="#{h text}" width="#{width}" height="#{height}" class="tdiarytimes">|
	end

	result

end
