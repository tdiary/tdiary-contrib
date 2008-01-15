#!/usr/bin/env ruby

# windex.rb $Revision: 1.2 $
#
# windex: 索引を生成する
#   パラメタ:
#     str:      キーワード文字列
#     readname: 読み仮名
#
# wikw: 索引からアンカーを生成する
#   パラメタ:
#     str:      キーワード文字列
#
# このファイルをtDiaryのトップディレクトリにも配置し、CGIとして
# 実行することで索引ページを出力できます。
#
# CGI動作時の引数
#   http://(日記URL)/windex.rb?kw=(キーワード文字列)
#   とキーワードを指定してアクセスすることでそのキーワードに関係する日記の
#   日付一覧を出力できます。一つだけの場合にはその日付の日記への
#   リダイレクトを出力します。
#
# tdiary.confによる設定
#   @options['windex.generate_all'] = true
#     全ての日記から索引を生成します。これは時間がかかるので、索引の全生成を
#     行いたいときだけtrueに設定して更新を行うような使い方を想定しています。
#
# Copyright (c) 2003 Gony <gony@sm.rim.or.jp>
# Distributed under the GPL
#

mode = ""
if $0 == __FILE__
	mode = "CGI"
	if FileTest.symlink?(__FILE__) == true
		org_path = File.dirname(File.readlink(__FILE__))
	else
		org_path = File.dirname(__FILE__)
	end
	$:.unshift(org_path)
	require "pstore"
	require "tdiary"

	tdiarybase = TDiary::TDiaryBase
else
	tdiarybase = TDiaryBase
end

class WITDiary < tdiarybase
	def load_plugins
		super
	end

	def generate_wordindex(date,plugin,index)
		wordindex = WIWordIndex.new
		@io.transaction(date) do |diaries|
			wordindex.generate(diaries,plugin,index)
		end

		return wordindex
	end
end

class WIWordIndex
	def initialize
		@windex = {}
		@dates = []
	end

	def generate(diaries,plugin,index)
		diaries.each_value do |diary|
			num_section = 1
			diary.each_section do |section|
				anchor = index \
				       + plugin.anchor(diary.date.strftime("%Y%m%d")) \
				       + "#p%02d" % num_section
				if section.subtitle != nil
					scan(section.subtitle,anchor)
				end
				scan(section.body,anchor)
				num_section = num_section + 1
			end
		end
	end

	def load(dir)
		@windex = {}
		Dir.mkdir(dir) unless File.directory?(dir)
		PStore.new(dir + "/windex").transaction do |pstore|
			@dates = pstore.roots
			@dates.each do |key|
				windex_tmp = pstore[key]
				windex_tmp.each_key do |key_windex|
					if @windex.has_key?(key_windex) == false
						@windex[key_windex] = {"readname" => nil,
						                       "anchor" => []}
					end
					if @windex[key_windex]["readname"] == nil \
						&& windex_tmp[key_windex].has_key?("readname") == true
							@windex[key_windex]["readname"] = windex_tmp[key_windex]["readname"]
					end
					@windex[key_windex]["anchor"].concat(windex_tmp[key_windex]["anchor"])
				end
			end
		end
	end

	def save(dir,keyname)
		if File.directory?(dir) == false
			Dir.mkdir(dir,0755)
		end
		PStore.new(dir + "/windex").transaction do |pstore|
			pstore[keyname] = @windex
		end
	end

	def generate_html(page)
		return page.generate_html(@windex)
	end

	def has_key?(key)
		return @windex.has_key?(key)
	end

	def [](key)
		return @windex[key]
	end

private
	def scan(body,anchor)
		to_delimiter_end = {
			"(" => ")","[" => "]","{" => "}","<" => ">",
		}

		wistrs = body.scan(%r[<%\s*=\s*windex\s*[^(<%)]*\s*%>])
		wistrs.each do |wistr|
			# 引数抽出
			argstr = wistr.gsub(%r[<%\s*=\s*windex\s*],"")
			argstr = argstr.gsub(%r[\s*%>],"")
			args = []
			flag_done = false
			while flag_done == false
				pos_delimiter = argstr.index(%r['|"|%[Qq].]) #"'
				if pos_delimiter != nil
					# デリミタ文字取得
					delimiter = argstr.scan(%r['|"|%[Qq].])[0] #"'
					if delimiter.length == 3
						delimiter_end = delimiter[2].chr
						if to_delimiter_end.has_key?(delimiter_end)
							delimiter_end = to_delimiter_end[delimiter_end]
						end
					else
						delimiter_end = delimiter
					end

					# デリミタまでの文字列を削除
					argstr = argstr[(pos_delimiter + delimiter.length)..-1]
					pos_delimiter = argstr.index(delimiter_end)
					if pos_delimiter != nil
						if pos_delimiter > 0
							# 引数として取得
							args << argstr[0..(pos_delimiter - 1)]
						else
							args << ""
						end
						# デリミタまでの文字列を削除
						argstr = argstr[(pos_delimiter + delimiter_end.length)..-1]
					else
						flag_done = true
					end
				else
					flag_done = true
				end
			end

			if args.length > 0
				if @windex.has_key?(args[0]) == false
					# ハッシュを生成
					@windex[args[0]] = {"readname" => nil,"anchor" => []}
				end
				if args.length > 1 && @windex[args[0]]["readname"] == nil && args[1] != ""
					@windex[args[0]]["readname"] = args[1]
				end
				@windex[args[0]]["anchor"] << anchor
			end
		end
	end
end

class WIIndexPage
	def initialize(title,css)
		@title = title
		@css = css
	end

	def generate_html(windex)
		body = ""

		# 大項目名 => 名前の配列 のハッシュを生成
		subindex_to_name = {}
		windex.keys.each do |key|
			subindex = ""
			if windex[key]["readname"] != nil
				subindex = get_subindex(windex[key]["readname"])
			else
				subindex = get_subindex(key)
			end
			if subindex_to_name.has_key?(subindex) == false
				subindex_to_name[subindex] = []
			end
			subindex_to_name[subindex] << key
		end

		# 大項目名ごとにHTMLを生成
		if subindex_to_name.has_key?("記号") == true
			body << generate_html_subindex(windex,subindex_to_name,"記号")
		end
		subindex_to_name.keys.sort.each do |key|
			if key != "記号"
				body << generate_html_subindex(windex,subindex_to_name,key)
			end
		end

		body = <<-BODY
			<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
			<html>
				<head>
					<title>#{h @title}(索引)</title>
					#{@css}
				</head>
				<body>
					<h1>#{@title} [索引]</h1>
					<div class="day"><div class="body">
						#{body}
					</div></div>
				</body>
			</html>
			BODY

		return body
	end

private
	def generate_html_subindex(windex,subindex_to_name,key)
		readname_to_name = {}
		subindex_to_name[key].each do |name|
			key_new = ""
			if windex[name]["readname"] != nil
				key_new = windex[name]["readname"]
			else
				key_new = name
			end
			if readname_to_name.has_key?(key_new) == false
				readname_to_name[key_new] = []
			end
			readname_to_name[key_new] << name
		end

		body = %Q[<div class="section"><h2>#{key}</h2>\n]

		# 読み仮名のソートでループ -> 名前のソートでループ
		keys = readname_to_name.keys
		if keys.empty? == false
			keys.sort.each do |readname|
				readname_to_name[readname].sort.each do |name|
					body << "<p>#{name} ... "
					num_anchor = 1
					windex[name]["anchor"].sort.each do |anchor|
						body = body + %Q[<a href="#{h anchor}">#{num_anchor}</a>]
						if num_anchor < windex[name]["anchor"].length
							body = body + ","
						end
						num_anchor = num_anchor + 1
					end
					body << "</p>"
				end
			end
		end
		body << "\n</div>\n"

		return body
	end

	def get_subindex(name)
		to_plainhiragana = {
			"ぁ" => "あ","ぃ" => "い","ぅ" => "う","ぇ" => "え","ぉ" => "お",
			"が" => "か","ぎ" => "き","ぐ" => "く","げ" => "け","ご" => "こ",
			"ざ" => "さ","じ" => "し","ず" => "す","ぜ" => "せ","ぞ" => "そ",
			"だ" => "た","ぢ" => "ち","っ" => "つ","づ" => "つ","で" => "て","ど" => "と",
			"ば" => "は","ぱ" => "は","び" => "ひ","ぴ" => "ひ","ぶ" => "ふ","ぷ" => "ふ","べ" => "へ","ぺ" => "へ","ぼ" => "ほ","ぽ" => "ほ",
			"ゃ" => "や","ゅ" => "ゆ","ょ" => "よ",
			"ゎ" => "わ","ヴ" => "う","ヵ" => "か","ヶ" => "け",
		}
		to_1byte = {
			"！" => "!",'”' => '"',"＃" => "#","＄" => "$","％" => "%","＆" => "&","’" => "'","（" => "(","）" => ")","＊" => "*","＋" => "+","，" => ",","−" => "-","．" => ".","／" => "/",
			"０" => "0","１" => "1","２" => "2","３" => "3","４" => "4","５" => "5","６" => "6","７" => "7","８" => "8","９" => "9","：" => ":","；" => ";","＜" => "<","＝" => "=","＞" => ">","？" => "?",
			"＠" => "@","Ａ" => "A","Ｂ" => "B","Ｃ" => "C","Ｄ" => "D","Ｅ" => "E","Ｆ" => "F","Ｇ" => "G","Ｈ" => "H","Ｉ" => "I","Ｊ" => "J","Ｋ" => "K","Ｌ" => "L","Ｍ" => "M","Ｎ" => "N","Ｏ" => "O",
			"Ｐ" => "P","Ｑ" => "Q","Ｒ" => "R","Ｓ" => "S","Ｔ" => "T","Ｕ" => "U","Ｖ" => "V","Ｗ" => "W","Ｘ" => "X","Ｙ" => "Y","Ｚ" => "Z","［" => "[","￥" => "\\","］" => "]","＾" => "^","＿" => "_",
			"ａ" => "a","ｂ" => "b","ｃ" => "c","ｄ" => "d","ｅ" => "e","ｆ" => "f","ｇ" => "g","ｈ" => "h","ｉ" => "i","ｊ" => "j","ｋ" => "k","ｌ" => "l","ｍ" => "m","ｎ" => "n","ｏ" => "o",
			"ｐ" => "p","ｑ" => "q","ｒ" => "r","ｓ" => "s","ｔ" => "t","ｕ" => "u","ｖ" => "v","ｗ" => "w","ｘ" => "x","ｙ" => "y","ｚ" => "z","｛" => "{","｜" => "|","｝" => "}","￣" => "~",
		}

		topchr = name[0,1]
		if topchr.count("\xA1-\xFE") == 1
			# 2バイト文字
			topchr = name[0,2]
		end
		if to_1byte.has_key?(topchr) == true
			topchr = to_1byte[topchr]
		end
		if topchr.length == 1
			# 1バイト文字の処理
			topchr = topchr.upcase
			
			if (0x21 <= topchr[0] && topchr[0] <= 0x2F) \
				|| (0x3A <= topchr[0] && topchr[0] <= 0x40) \
				|| (0x5B <= topchr[0] && topchr[0] <= 0x60) \
				|| (0x7B <= topchr[0] && topchr[0] <= 0x7B)
					topchr = "記号"
			end
		else
			# 2バイト文字の処理
			# カタカナ->ひらがな変換
			code = topchr[0] * 0x100 + topchr[1]
			if 0xA5A1 <= code && code <= 0xA5F3
				topchr = 0xA4.chr + topchr[1].chr
			end

			# 濁点 / 半濁点 撥音など変換
			if to_plainhiragana.has_key?(topchr) == true
				topchr = to_plainhiragana[topchr]
			end
		end

		return topchr
	end
end

class WIRedirectPage
	def initialize(key)
		@key = key
	end

	def generate_html(windex)
		anchor = windex[@key]["anchor"][0]
		body = <<-BODY
			<html>
				<head>
					<meta http-equiv="refresh" content="0;url=#{h anchor}">
					<title>moving...</title>
				</head>
				<body>Wait or <a href="#{h anchor}">Click here!</a></body>
			</html>
			BODY

		return body
	end
end

class WISinglePage
	def initialize(title,date_format,css,key)
		@title = title
		@date_format = date_format
		@css = css
		@key = key
	end

	def generate_html(windex)
		anchors = windex[@key]["anchor"]
		body = %Q[<div class="section"><h2>#{@key}</h2>\n]
		anchors.sort.each do |anchor|
			str_date = anchor.scan(/\d{8}/)[0]
			date = Time.local(str_date[0..3].to_i,str_date[4..5].to_i,str_date[6..7].to_i)
			body << %Q[<p><a href="#{h anchor}">#{date.strftime(@date_format)}</a></p>\n]
		end
		body << "\n</div>\n"
		body = <<-BODY
			<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
			<html>
				<head>
					<title>#{h @title}(索引)</title>
					#{@css}
				</head>
				<body>
					<h1>#{@title} [索引]</h1>
					<div class="day"><div class="body">
						#{body}
					</div></div>
				</body>
			</html>
			BODY

		return body
	end
end

class WIErrorPage
	def initialize(title,css,key)
		@title = title
		@css = css
		@key = key
	end

	def generate_html(windex)
		body = <<-BODY
			<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
			<html>
				<head>
					<title>#{h @title}(索引)</title>
					#{@css}
				</head>
				<body>
					<h1>#{@title} [索引]</h1>
					<div class="day"><div class="body">
						キーワード「#{h @key}」は登録されていません。
					</div></div>
				</body>
			</html>
			BODY

		return body
	end
end

def windex(str,readname = "")
	return str
end

def wikw(str)
	if @wordindex.has_key?(str) == true
		anchors = @wordindex[str]["anchor"]
		if anchors.length == 1
			return %Q[<a href="#{h anchors[0]}">#{str}</a>]
		else
			body = "#{str}("
			num_anchor = 1
			anchors.sort.each do |anchor|
				body << %Q[<a href="#{h anchor}">#{num_anchor}</a>]
				if num_anchor < anchors.length
					body << ","
				end
				num_anchor = num_anchor + 1
			end
			body << ")"

			return body
		end
	end

	return str
end

if mode != "CGI"
	@wordindex = WIWordIndex.new
	@wordindex.load(@cache_path + "/windex")

	add_update_proc do
		if @conf.options["windex.generate_all"] == true
			tdiary = WITDiary.new(@cgi,"day.rhtml",@conf)
			@years.each_key do |year|
				@years[year.to_s].each do |month|
					date = Time::local(year,month)
					wordindex = tdiary.generate_wordindex(date,self,@conf.index)
					wordindex.save(@cache_path + "/windex",date.strftime('%Y%m'))
				end
			end
		else
			wordindex = WIWordIndex.new
			wordindex.generate(@diaries,self,@conf.index)
			wordindex.save(@cache_path + "/windex",@date.strftime('%Y%m'))
		end
	end
else
	cgi = CGI.new
	conf = TDiary::Config.new(cgi)
	cache_path = conf.data_path + "cache"
	plugin = WITDiary.new(cgi,"day.rhtml",conf).load_plugins

	wordindex = WIWordIndex.new
	wordindex.load(cache_path + "/windex")
	if cgi.valid?('kw') == true
		key = cgi.params['kw'][0]
		if wordindex.has_key?(key) == true
			num_anchor = wordindex[key]["anchor"].length
			if num_anchor == 0
				page = WIErrorPage.new(conf.html_title,plugin.css_tag,key)
			elsif num_anchor == 1
				page = WIRedirectPage.new(key)
			else
				page = WISinglePage.new(conf.html_title,conf.date_format,plugin.css_tag,key)
			end
		else
			page = WIErrorPage.new(conf.html_title,plugin.css_tag,key)
		end
	else
		page = WIIndexPage.new(conf.html_title,plugin.css_tag)
	end
	body = wordindex.generate_html(page)

	header = {
		"type" => "text/html",
		"charset" => "EUC-JP",
		"Content-Length" => body.size.to_s,
		"Pragma" => "no-cache",
		"Cache-Control" => "no-cache",
		"Vary" => "User-Agent",
	}
	head = cgi.header(header)

	print head
	print body
end
