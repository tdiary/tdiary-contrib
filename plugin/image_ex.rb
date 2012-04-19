# image_plugin_ex.rb
# version 0.3
# -pv-
# 
# 名称:
# 絵日記Plugin機能追加版
#
# 概要:
# 日記更新画面からの画像アップロード、サムネイル作成、本文への表示
#
# 使う場所:
# 本文
#
# 使い方:
# image( number, 'altword', thumbnail ) - 画像を表示します。
#    number - 画像の番号0、1、2等
#    altword - imgタグの altに入れる文字列
#    thumbnail - サムネイル(小さな画像)を指定する(省略可)
#
# image_left( number, 'altword', thumbnail ) - imageにclass=leftを追加します。
# image_right( number, 'altword', thumbnail ) - imageにclass=rightを追加します。
#
# image_link( number, 'desc' ) - 画像へのリンクを生成します。
#    number - 画像の番号0、1、2等
#    desc - 画像の説明
#
# その他:
# tDiary version 1.5.4以降で動作します。
# tdiary.confで、
# 画像ファイルを保存するディレクトリ
#  @options['image.dir']
# 画像ファイルのURL
#  @options['image.url']
# 縮小画像の生成方法
#  @options['image.url']
#     0 - 縮小画像を生成しない
#     1 - ImageMagickのconvertで縮小画王を生成
#     2 - netpbm群で縮小画王を生成
# を設定してください。
# また、@secure = trueな環境では動作しません。
#
# 詳しくは、
# http://shimoi.s26.xrea.com/hiki/hiki.xcg?TdiaryEnikkiEx
# をご覧下さい。
#
# ライセンスについて:
# Copyright (c) 2002 Daisuke Kato <dai@kato-agri.com>
# Copyright (c) 2002 Toshi Okada <toshi@neverland.to>
# Copyright (c) 2003 Yoshimi KURUMA <yoshimik@iris.dti.ne.jp>
#
# You can redistribute it and/or modify it under GPL2.
#
=begin Changelog
2003-05-16 Yoshimi KURUMA <yoshimik@iris.dti.ne.jp>
	* method 'image' is extended to show a thumbnail.
	* new method: 'image_link'.
  * version 0.3

2003-05-16 Yoshimi KURUMA <yoshimik@iris.dti.ne.jp>
	* modify illegal option names.
	* version 0.2.

2003-05-16 Yoshimi KURUMA <yoshimik@iris.dti.ne.jp>
	* support manual upload of thumbnail when useresize == 0

2003-04-27 Yoshimi KURUMA <yoshimik@iris.dti.ne.jp>
	* link element is removed when no thumbnail.

2003-04-25 Yoshimi KURUMA <yoshimik@iris.dti.ne.jp>
	* add JavaScript for insert plugin tag into diary.
	* upload/delete form style changed.

2003-04-24 Yoshimi KURUMA <yoshimik@iris.dti.ne.jp>
	* upload/delete form style changed.

2003-04-22 Yoshimi KURUMA <yoshimik@iris.dti.ne.jp>
	* version 0.1	first form_proc version.
=end

@image_dir = @options && @options['image.dir'] || './images/'
@image_dir.chop! if /\/$/ =~ @image_dir
@image_url = @options && @options['image.url'] || './images/'
@image_url.chop! if /\/$/ =~ @image_url
@imageex_thumbnailsize = @options && @options['image_ex.previewsize'] || 120
@imageex_yearlydir = @options && @options['image_ex.yearlydir'] || 0

if @conf.smartphone?
	enable_js("image_ex.js")
end


add_body_enter_proc(Proc.new do |date|	
	@image_date = date.strftime("%Y%m%d")
	@image_year = date.strftime("%Y")
	""
end)


def image( id, alt = "image", id2 = nil, width = nil, place="none" )
	@image_date ||= @date.strftime("%Y%m%d")
	@image_year ||= @date.strftime("%Y")

	if @imageex_yearlydir == 1
		image_url = %Q[#{@image_url}/#{@image_year}/]
		image_dir = %Q[#{@image_dir}/#{@image_year}/]
	else
		image_url = %Q[#{@image_url}/]
		image_dir = %Q[#{@image_dir}/]
	end

	image_dir.untaint
	Dir.mkdir(image_dir) unless File.directory?(image_dir)
	
	list = imageList(@image_date, image_dir).untaint
	slist = imageList(@image_date, image_dir, "s").untaint
	
	if width
		width_tag = %Q[width="#{h width}"]
	else
		width_tag = ""
	end

	if id2
		%Q[<a href="#{h image_url}#{h list[id.to_i]}"><img class="image-ex #{h place}" src="#{h image_url}#{h list[id2.to_i]}" alt="#{h alt}"></a>]
	else
		if slist[id.to_i]
			%Q[<a href="#{h image_url}#{h list[id.to_i]}"><img src="#{h image_url}#{h slist[id.to_i]}" alt="#{h alt}" title="#{h alt}" #{width_tag} class="image-ex #{h place}"></a>]
		else
			if list[id.to_i]
#				%Q[<a href="#{h image_url}#{h list[id.to_i]}"><img src="#{h image_url}#{h list[id.to_i]}" alt="#{h alt}" #{width_tag} class="image-ex #{h place}"></a>]
				%Q[<img src="#{h image_url}#{h list[id.to_i]}" alt="#{h alt}" title="#{h alt}" #{width_tag} class="image-ex #{h place}">]
			end
		end
	end
end

def image_left( id, alt = "image", id2 = nil, width=nil )
	image( id, alt, id2, width, "left" )
end

def image_right( id, alt = "image", id2 = nil, width=nil )
	image( id, alt, id2, width, "right" )
end

def image_link( id, str )
	@image_date ||= @date.strftime("%Y%m%d")
	@image_year ||= @date.strftime("%Y")
	if @imageex_yearlydir == 1
		image_url = %Q[#{@image_url}/#{@image_year}/]
		image_dir = %Q[#{@image_dir}/#{@image_year}/]
	else
		image_url = %Q[#{@image_url}/]
		image_dir = %Q[#{@image_dir}/]
	end
	list = imageList(@image_date, image_dir).untaint
	%Q[<a href="#{h image_url}#{h list[id.to_i]}">#{str}</a>]
end

###

def imageList(date, image_dir='@image_dir', prefix="")
	date = "#{prefix}"+date
	image_path = []
	Dir.foreach(image_dir){ |file|
		if file =~ /(.*)\_(.*)\.(.*)/
			if $1 == date
				image_path[$2.to_i] = file
			end
		end
	}
	image_path
end


add_form_proc do |date|
	begin
#		ENV['PATH'] = nil

		imageex_useresize = @options && @options['image_ex.useresize'] || 0
		imageex_converttype = @options && @options['image_ex.converttype'] || 0
		imageex_thresholdsize = @options && @options['image_ex.thresholdsize'] || 160
		imageex_convertedwidth = @options && @options['image_ex.convertedwidth'] || 160
		imageex_convertedheight = @options && @options['image_ex.convertedheight'] || 120

		if imageex_useresize == 1 || imageex_useresize ==2
			begin
				require 'image_size.rb'
			rescue LoadError
				imageex_useresize = 0
			end
		end

		if imageex_useresize == 1
			def resize_image(orig, new, width, height, imageex_convertedwidth, imageex_convertedheight, orig_type, new_type)
				imageex_convertpath = @options && @options['image_ex.convertpath'] || "convert"
				imageex_convertpath
				
				if width > height
					imageex_convertedsize = %Q[#{imageex_convertedwidth}x#{imageex_convertedheight}]
					imageex_convertedsize
				else
					imageex_convertedsize = %Q[#{imageex_convertedheight}x#{imageex_convertedwidth}]
					imageex_convertedsize
				end
				system(imageex_convertpath , "-geometry", imageex_convertedsize , orig, new)
				if FileTest::size?( new ) == 0
					File::delete( new )
				end
			end
		elsif imageex_useresize == 2
			def resize_image(orig, new, width, height, imageex_convertedwidth, imageex_convertedheight, orig_type, new_type)
				pnmscale = @options && @options['image_ex.pnmscalepath'] || "pnmscale"
				jpegtopnm = @options && @options['image_ex.jpegtopnmpath'] || "jpegtopnm"
				pnmtojpeg = @options && @options['image_ex.pnmtojpegpath'] || "pnmtojpeg"
				pngtopnm = @options && @options['image_ex.pngtopnmpath'] || "pngtopnm"
				pnmtopng = @options && @options['image_ex.pnmtopngpath'] || "pnmtopng"
				giftopnm = @options && @options['image_ex.giftopnmpath'] || "giftopnm"
				tifftopnm = @options && @options['image_ex.tifftopnmpath'] || "tifftopnm"
				bmptopnm = @options && @options['image_ex.bmptopnmpath'] || "bmptopnm"
				
				downtype = orig_type.downcase
				topnm = eval("#{downtype}topnm")
				
				if new_type == "jpg"
					pnmto = pnmtojpeg
				elsif new_type == "png"
					pnmto = pnmtopng
				end
				
				if width > height
					imageex_convertedsize ="#{imageex_convertedwidth}"
				else
					imageex_convertedsize ="#{imageex_convertedheight}"
				end
				com_line =%Q[#{topnm} #{orig} | #{pnmscale} --width #{imageex_convertedsize} | #{pnmto} > #{new}]
				system( com_line )
				if FileTest::size?( new ) == 0
					File::delete( new )
				end
			end
		end

		def dayimagelist( image_dir, image_date, prefix="")
			image_path = []
			image_dir.untaint
			Dir.foreach(image_dir){ |file|
				if file=~ /(.*)\_(.*)\.(.*)/
					if $1 == "#{prefix}" + image_date.to_s
						image_path[$2.to_i] = file
					end
				end
			}
			return image_path
		end
	
		if @cgi.params['plugin_image_add'][0] && @cgi.params['plugin_image_file'][0].original_filename != ''
			image_dir = @cgi.params['plugin_image_dir'][0].read.untaint
			image_filename = ''
			image_extension = ''
			image_date = date.strftime("%Y%m%d")
			image_filename = @cgi.params['plugin_image_file'][0].original_filename
			if image_filename =~ /(\.jpg|\.jpeg|\.gif|\.png)\z/i
				image_extension = $1

				image_name = dayimagelist(image_dir, image_date)
				image_file = image_dir+image_date+"_"+image_name.length.to_s+image_extension.downcase

				image_file.untaint
				File::umask( 022 )
				File::open( image_file, "wb" ) {|f|
					f.print @cgi.params['plugin_image_file'][0].read
				}
			end
			
			if imageex_useresize == 1 or imageex_useresize == 2
				open(image_file,"rb") do |fh|
					img = ImageSize.new(fh.read)
					width = img.get_width
					height = img.get_height
					orig_type = img.get_type
					if imageex_converttype == 0
						new_type = "jpg"
					elsif imageex_converttype == 1
						new_type = "png"
					end
					
					if width
						if width > imageex_thresholdsize or height > imageex_thresholdsize
							small_image_file = %Q[#{image_dir}s#{image_date}_#{image_name.length.to_s}.#{new_type}]
							resize_image(image_file, small_image_file, width, height, imageex_convertedwidth, imageex_convertedheight, orig_type, new_type)
						end
					end
				end
			end

		elsif @cgi.params['plugin_image_thumbnail'][0] && @cgi.params['plugin_image_file'][0].original_filename != ''
			image_dir = @cgi.params['plugin_image_dir'][0].read.untaint
			image_filename = ''
			image_extension = ''
			image_date = date.strftime("%Y%m%d")
			image_filename = @cgi.params['plugin_image_file'][0].original_filename
			if image_filename =~ /(\.jpg|\.jpeg|\.gif|\.png)\z/i
				image_extension = $1
				image_name = @cgi.params['plugin_image_name'][0].read.untaint
				image_file=image_dir+"s"+image_name+image_extension.downcase

				image_file.untaint
				File::umask( 022 )
				File::open( image_file, "wb" ) {|f|
					f.print @cgi.params['plugin_image_file'][0].read
				}
			end

		elsif @cgi.params['plugin_image_del'][0]
			image_dir = @cgi.params['plugin_image_dir'][0]
			image_date = date.strftime("%Y%m%d")
			image_name = dayimagelist( image_dir, image_date)
			image_name2= dayimagelist( image_dir, image_date, "s")

			@cgi.params['plugin_image_id'].untaint.each do |id|
				if image_name[id.to_i]
					image_file=image_dir+image_name[id.to_i]
					image_file.untaint
					if File::exist?(image_file)
						File::delete(image_file)
					end
				end
				if image_name2[id.to_i]
					image_file2=image_dir+image_name2[id.to_i]
					image_file2.untaint
					if File::exist?(image_file2)
						File::delete(image_file2)
					end
				end
			end
		end
	rescue Exception
		puts "Content-Type: text/plain\n\n"
		puts "#$! (#{$!.type})"
		puts ""
		puts $@.join( "\n" )
	end

	if @imageex_yearlydir == 1
		image_dir = %Q[#{@image_dir}/#{@date.year}/]
	else
		image_dir = %Q[#{@image_dir}/]
	end

	if @imageex_yearlydir == 1
		image_url = %Q[#{@image_url}/#{@date.year}/]
	else
		image_url = %Q[#{@image_url}/]
	end

	Dir.mkdir(image_dir) unless File.directory?(image_dir)


	n_image = imageList(@date.strftime("%Y%m%d"), image_dir).length
	list = imageList(@date.strftime("%Y%m%d"), image_dir)
	slist = imageList(@date.strftime("%Y%m%d"), image_dir, "s")
	
	pretable=""
	posttable=""
	
	if n_image > 0
		pretable<< %Q[<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0">]
		posttable << %Q[</TR></TABLE>]
	end

	if @conf.respond_to?(:style) and @conf.style =~ /Wiki$/i
		image_plugin_tag1 = "{{"
		image_plugin_tag2 = "}}"
	elsif @conf.respond_to?(:style) and @conf.style =~ /RD$/i
		image_plugin_tag1 = "((%"
		image_plugin_tag2 = "%))"
	else
		image_plugin_tag1 = "&lt;%="
		image_plugin_tag2 = "%&gt;"
	end
	
	r = ''
	r << %Q[
		<script type="text/javascript">
		<!--
		var elem=null
		function ins(val){
			elem.value+=val
		}
		window.onload=function(){
			for(var i=0;i<document.forms.length;i++){
				for(var j=0;j<document.forms[i].elements.length;j++){
					var e=document.forms[i].elements[j]
					if(e.type&&e.type=="textarea"){
						if(elem==null){
							elem=e
						}
						e.onfocus=new Function("elem=this")
					}
				}
			}
		}
		//-->
		</script>
	]
	i = ''
	i << "<tr>"
	nt=0
	id=0

	while id < n_image do
		thumbnail_tag = ''
		if slist[id.to_i]
			src_tag = %Q[src="#{h image_url}#{h slist[id.to_i]}"]
			alt_tag = %Q[alt="#{h slist[id.to_i]}"]
		else
			src_tag = %Q[src="#{h image_url}#{h list[id.to_i]}"]
			alt_tag = %Q[alt="#{h list[id.to_i]}"]
			thumbnail_tag = %Q[<form class="update" method="post" enctype="multipart/form-data" action="#{h @update}">#{csrf_protection}<input type="hidden" name="plugin_image_name" value="#{date.strftime( '%Y%m%d' )}_#{h id}"><input type="hidden" name="plugin_image_dir" value="#{h image_dir}"><input type="hidden" name="plugin_image_thumbnail" value="true"><input type="hidden" name="date" value="#{date.strftime( '%Y%m%d' )}"><input type="file" name="plugin_image_file"><input type="submit" name="plugin" value="サムネイル"></form>] if imageex_useresize == 0
		end
		
		ptag = "#{image_plugin_tag1}image #{id}, '画像の説明'#{image_plugin_tag2}"
		
		i<< %Q[<td><table border="1" cellpadding="1" cellspacing="1"><tr><td style="text-align:center"><input type="button" onclick="ins(&quot;#{ptag}&quot;)" value="本文に追加"></td></tr><tr><td style="text-align:center">#{image_plugin_tag1}image #{h id},'title#{h id}'#{image_plugin_tag2}</td></tr><tr><td width="#{@imageex_thumbnailsize * 1.5}" height="#{@imageex_thumbnailsize * 1.3}" style="text-align:center">
<img class="form" #{src_tag} #{alt_tag} height="#{@imageex_thumbnailsize}" ></tr><tr><td>#{thumbnail_tag}<form class="update" method="post" action="#{h @update}">#{csrf_protection}<input type="hidden" name="plugin_image_del" value="true"><input type="hidden" name="date" value="#{date.strftime( '%Y%m%d' )}"><input type="hidden" name="plugin_image_id" value="#{h id}"><input type="submit" name="plugin" value="画像を削除"><input type="hidden" name="plugin_image_dir" value="#{h image_dir}"></form>
</tr></table></td>] if slist[id.to_i] || list[id.to_i]
		nt += 1 if slist[id.to_i] || list[id.to_i]
		
		if nt > 0 and nt%2 == 0
			i<< %Q[</TR></TABLE><TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0"><TR><TD>]
		end
		id +=1
	end

	if n_image > 0
		r << %Q[<div class="form">
		<div class="caption">
		絵日記(一覧・削除)
		</div>

		#{pretable}
		#{i}
		#{posttable}

		</div>]
	end

	r << %Q[<div class="form">
	<div class="caption">
	絵日記(追加)
	</div>
	<form class="update" method="post" enctype="multipart/form-data" action="#{h @update}">
	#{csrf_protection}
	<input type="hidden" name="plugin_image_dir" value="#{h image_dir}">
	<input type="hidden" name="plugin_image_add" value="true">
	<input type="file"	 name="plugin_image_file">
	<input type="hidden" name="date" value="#{date.strftime( '%Y%m%d' )}">
	<input type="submit" name="plugin" value="画像の追加">
	</form></div>]
end

# vim: set ts=3 sw=3 noexpandtab :
