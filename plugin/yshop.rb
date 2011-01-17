# yshop.rb $Revision: 3 $
# Copyright (C) 2008 Michitaka Ohno <elpeo@mars.dti.ne.jp>
# You can redistribute it and/or modify it under GPL2.

# ja/yshop.rb
@yshop_label_conf ='Yahoo!ショッピング'
@yshop_label_appid = 'アプリケーションID'
@yshop_label_affiliate_type = 'アフィリエイトの種類'
@yshop_label_yid = 'Yahoo! JAPANアフィリエイト'
@yshop_label_vc = 'バリューコマースアフィリエイト'
@yshop_label_affiliate_id = 'アフィリエイトID'
@yshop_label_imgsize = '表示するイメージのサイズ'
@yshop_label_medium = '普通'
@yshop_label_small = '小さい'
@yshop_label_clearcache = 'キャッシュの削除'
@yshop_label_clearcache_desc = 'イメージ関連情報のキャッシュを削除する(Yahoo!ショッピング上の表示と矛盾がある場合に試して下さい)'

require 'rexml/document'
require 'open-uri'
require 'kconv'

eval( <<-TOPLEVEL_CLASS, TOPLEVEL_BINDING )
require 'erb'
include ERB::Util
TOPLEVEL_CLASS

def yshop_get( param, store )
	if Hash === param then
		param = param.dup
	elsif /^(\d{8}|\d{13})$/ === param then
		param = {:jan => $1}
	else
		param = {:query => param.to_s}
	end
	param[:store_id] = store if store
	cache = "#{@cache_path}/yshop"
	Dir::mkdir( cache ) unless File::directory?( cache )
	file = "#{cache}/#{u( param.to_s )}.xml"
	begin
		xml = File::read( file )
	rescue
		qs = []
		qs << 'appid='+u( @conf['yshop.appid']||'YahooDemo' )
		qs << 'affiliate_type='+u( @conf['yshop.affiliate_type'] ) if @conf['yshop.affiliate_type']
		qs << 'affiliate_id='+u( @conf['yshop.affiliate_id'] ) if @conf['yshop.affiliate_id']
		[:query, :jan, :isbn, :store_id].each do |item|
			qs << "#{item}="+u( param[item].toutf8 ) if param.include?( item )
		end
		qs << 'hits=1'
		xml = open( 'http://shopping.yahooapis.jp/ShoppingWebService/V1/itemSearch?'+(qs*'&') ){|f| f.read}
		open( file, 'wb' ) {|f| f.write( xml )} if xml
	end
	REXML::Document.new( xml ).root if xml
end

def yshop_get_image( doc )
	img = Struct.new( :size, :src, :width, :height ).new
	if @conf['yshop.imgsize'] == 1 then
		img.size = 'Small'
		img.width = img.height = 76
	else
		img.size = 'Medium'
		img.width = img.height = 146
	end
	begin
		img.src = doc.elements["Result/Hit/Image/#{img.size}"].text
	rescue
		img.src = "http://i.yimg.jp/images/sh/noimage/#{img.width}x#{img.height}.gif"
	end
	img
end

def yshop_get_brands( doc )
	begin
		@conf.to_native( doc.elements['Result/Hit/Brands/Name'].text )
	rescue
		'-'
	end
end

def yshop_get_price( doc )
	begin
		r = doc.elements['Result/Hit/Price'].text
		nil while r.gsub!(/(.*\d)(\d\d\d)/, '\1,\2')
		"\\"+r
	rescue
		'(no price)'
	end
end

def yshop_get_shop( doc )
	begin
		@conf.to_native( doc.elements['Result/Hit/Store/Name'].text )
	rescue
		'-'
	end
end

def yshop_get_html( param, store, pos )
	doc = yshop_get( param, store )
	return unless doc && doc.attributes['totalResultsReturned'].to_i > 0
	name = @conf.to_native( doc.elements["Result/Hit/Name"].text )
	link = doc.elements["Result/Hit/Url"].text
	img = yshop_get_image( doc )
	r = %Q[<a href="#{h( link )}">]
	r << %Q[<img class="#{pos}" src="#{h( img.src )}" width="#{h( img.width )}" height="#{h( img.height )}" alt="#{h( name )}" title="#{h( name )}">] if img.src
	r << h( name )
	r << %Q[</a>]
end

def yshop_image( param, store = nil )
	yshop_get_html( param, store, 'amazon' )
end

def yshop_image_left( param, store = nil )
	yshop_get_html( param, store, 'left' )
end

def yshop_image_right( param, store = nil )
	yshop_get_html( param, store, 'right' )
end

def yshop_detail( param, store = nil )
	doc = yshop_get( param, store )
	return unless doc && doc.attributes['totalResultsReturned'].to_i > 0
	name = @conf.to_native( doc.elements["Result/Hit/Name"].text )
	link = doc.elements["Result/Hit/Url"].text
	img = yshop_get_image( doc )
	brands = yshop_get_brands( doc )
	price = yshop_get_price( doc )
	shop = yshop_get_shop( doc )
	<<-HTML
	<a href="#{h( link )}">
		<img class="amazon-detail left" src="#{h( img.src )}"
		width="#{h( img.width)}" height="#{h( img.height )}"
		alt="#{h( name )}" title="#{h( name )}">
	</a>
	<span class="amazon-title">#{h( name )}</span><br>
	<span class="amazon-author">#{h( brands )}</span><br>
	<span class="amazon-label">#{h( shop )}</span><br>
	<span class="amazon-price">#{h( price )}</span><br style="clear: left">
	HTML
end

add_conf_proc( 'yshop', @yshop_label_conf ) do
	yshop_conf_proc
end

def yshop_conf_proc
	if @mode == 'saveconf' then
		@conf['yshop.imgsize'] = @cgi.params['yshop.imgsize'][0].to_i
		if @cgi.params['yshop.clearcache'][0] == 'true' then
			Dir["#{@cache_path}/yshop/*"].each do |cache|
				File::delete( cache.untaint )
			end
		end
		if @cgi.params['yshop.appid'][0].empty? then
			@conf['yshop.appid'] = nil
		else
			@conf['yshop.appid'] = @cgi.params['yshop.appid'][0]
		end
		if @cgi.params['yshop.affiliate_id'][0].empty? then
			@conf['yshop.affiliate_type'] = nil
			@conf['yshop.affiliate_id'] = nil
		else
			@conf['yshop.affiliate_type'] = @cgi.params['yshop.affiliate_type'][0]
			@conf['yshop.affiliate_id'] = @cgi.params['yshop.affiliate_id'][0]
		end
	end

	<<-HTML
	<h3>#{@yshop_label_appid}</h3>
	<p><input name="yshop.appid" value="#{h( @conf['yshop.appid'] )}" size="100"></p>
	<h3>#{@yshop_label_affiliate_type}</h3>
	<p><select name="yshop.affiliate_type">
		<option value="yid"#{" selected" if @conf['yshop.affiliate_type'] == 'yid'}>#{@yshop_label_yid}</option>
		<option value="vc"#{" selected" if @conf['yshop.affiliate_type'] == 'vc'}>#{@yshop_label_vc}</option>
	</select></p>
	<h3>#{@yshop_label_affiliate_id}</h3>
	<p><input name="yshop.affiliate_id" value="#{h( @conf['yshop.affiliate_id'] )}" size="100"></p>
	<h3>#{@yshop_label_imgsize}</h3>
	<p><select name="yshop.imgsize">
		<option value="0"#{" selected" if @conf['yshop.imgsize'] == 0}>#{@yshop_label_medium}</option>
		<option value="1"#{" selected" if @conf['yshop.imgsize'] == 1}>#{@yshop_label_small}</option>
	</select></p>
	<h3>#{@yshop_label_clearcache}</h3>
	<p><label for="yshop.clearcache"><input type="checkbox" id="yshop.clearcache" name="yshop.clearcache" value="true">#{@yshop_label_clearcache_desc}</label></p>
	HTML
end
