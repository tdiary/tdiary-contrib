# -*- coding: utf-8 -*-
# section_footer.rb
#
# Copyright (c) 2005 SHIBATA Hiroshi <h-sbt@nifty.com>
# You can redistribute it and/or modify it under GPL2.
#

require 'digest/md5'
require 'open-uri'
require 'timeout'

def permalink( date, index, escape = true )
	ymd = date.strftime( "%Y%m%d" )
	uri = @conf.index.dup
	uri.sub!( %r|\A(?!https?://)|i, @conf.base_url )
	uri.gsub!( %r|/\.(?=/)|, "" ) # /././ -> /
	link = uri + anchor( "#{ymd}p%02d" % index )
	link.sub!( "#", "%23" ) if escape
	link
end

add_header_proc do
	<<-SCRIPT
	<link rel="stylesheet" href="theme/hatena_bookmark.css" type="text/css" media="all">
	<script type="text/javascript" src="http://b.hatena.ne.jp/js/BookmarkCommentViewerAllInOne.1.2.js" charset="utf-8"></script>
	<script type="text/javascript">
	initCreateRelAfterIcon();
	BookmarkCommentViewer.options['dateFormat'] = '%y-%m-%d';
	// BookmarkCommentViewer.options['blankCommentHide'] = true;
	BookmarkCommentViewer.options['tags'] = false;
	</script>
	SCRIPT
end

add_section_enter_proc do |date, index|
	@category_to_tag_list = {}
end

alias subtitle_link_original subtitle_link
def subtitle_link( date, index, subtitle )
	s = ''
	if subtitle then
		s = subtitle.sub( /^(\[([^\[]+?)\])+/ ) do
			$&.scan( /\[(.*?)\]/ ) do |tag|
				@category_to_tag_list[tag] = false # false when diary
			end
			''
		end
	end
	subtitle_link_original( date, index, s.strip )
end

add_section_leave_proc do |date, index|
	r = '<div class="tags">'

	# カテゴリタグの追加
	if @category_to_tag_list and not @category_to_tag_list.empty? then
		r << "Tags: "
		@category_to_tag_list.each do |tag, blog|
			if blog
				r << %Q|<a href="#{@index}?blogcategory=#{h tag}">#{tag}</a> |
			else
				r << category_anchor( "#{tag}" ).sub( /^\[/, '' ).sub( /\]$/, '' ) << ' '
			end
		end
	end

	# 「このエントリの Delicious history (JSON)」
	r << add_delicious_json(date, index)

	# 「このエントリを含む Delicious (画像API)」
	# r << add_delicious(date, index)

	# 「このエントリを含むはてなブックーク」
	r << add_hatenabm(date, index)

	# 「このエントリを含む livedoor クリップ」
	r << add_ldclip(date, index)

	# 「このエントリを含む Buzzurl」
	r << add_buzzurl(date, index)

	# 「このエントリを含む Yahoo!ブックマーク」
	r << add_yahoobm(date, index)

	# Permalinkの追加
	r << add_permalink(date, index)

	r << "</div>\n"
end

def add_permalink(date, index)
	r = " | "
	r << %Q|<a href="#{permalink(date, index, false)}">Permalink</a> |
	return r
end

def add_hatenabm(date, index)
	r = " | "
	r << %Q|<a href="http://b.hatena.ne.jp/entry/#{permalink(date, index)}"><img src="http://d.hatena.ne.jp/images/b_entry.gif" style="border: 0 none;vertical-align: middle;" title="#{@section_footer_hatenabm_label}" alt="#{@section_footer_hatenabm_label}" width="16" height="12"> <img src="http://b.hatena.ne.jp/entry/image/normal/#{permalink(date, index)}" style="border: 0 none;vertical-align: middle;"></a> <img src="http://r.hatena.ne.jp/images/popup.gif" style="border: 0 none;vertical-align: middle;" onclick="iconImageClickHandler(this, '#{permalink(date, index, false)}', event);" alt="">|
	return r
end

def add_ldclip(date, index)
	r = " | "
	r << %Q|<a href="http://clip.livedoor.com/page/#{permalink(date, index)}"><img src="http://parts.blog.livedoor.jp/img/cmn/clip_16_16_w.gif" width="16" height="16" style="border: 0 none;vertical-align: middle;" alt="#{@section_footer_ldclip_label}" title="#{@section_footer_ldclip_label}"> <img src="http://image.clip.livedoor.com/counter/#{permalink(date, index)}" style="border: 0 none;vertical-align: middle;"></a>|
	return r
end

def add_buzzurl(date, index)
	r = " | "
	r << %Q|<a href="http://buzzurl.jp/entry/#{permalink(date, index)}"><img src="http://buzzurl.jp/static/image/api/icon/add_icon_mini_10.gif" style="border: 0 none;vertical-align: middle;" title="#{@section_footer_buzzurl_label}" alt="#{@section_footer_buzzurl_label}" width="16" height="12" class="icon"> <img src="http://buzzurl.jp/api/counter/#{permalink(date, index)}" style="border: 0 none;vertical-align: middle;"></a>|
	return r
end

def add_delicious(date, index)
	url_md5 = Digest::MD5.hexdigest(permalink(date, index, false))

	r = " | "
	r << %Q|<a href="http://delicious.com/url/#{url_md5}"><img src="http://static.delicious.com/img/delicious.small.gif" width="10" height="10" style="border: 0 none;vertical-align: middle;" alt="#{@section_footer_delicious_label}" title="#{@section_footer_delicious_label}"> <img src="http://del.icio.us/feeds/img/savedcount/#{url_md5}?aggregate" style="border: 0 none;margin: 0;"></a>|
	return r
end

def add_delicious_json(date, index)
	require 'fileutils'
	begin
		require 'json'
	rescue
		retry if require 'rubygems'
	end

	url_md5 = Digest::MD5.hexdigest(permalink(date, index, false))
	cache_dir = "#{@cache_path}/delicious/#{date.strftime( "%Y%m" )}/"
	file_name = "#{cache_dir}/#{url_md5}.json"
	cache_time = 8 * 60 * 60  # 8 hour
	update = false
	count = 0

	r = " | "
	r << %Q|<a href="http://delicious.com/url/#{url_md5}"><img src="http://static.delicious.com/img/delicious.small.gif" width="10" height="10" style="border: 0 none;vertical-align: middle;" alt="#{@section_footer_delicious_label}" title="#{@section_footer_delicious_label}">|

	begin
		FileUtils.mkdir_p( cache_dir ) unless File::directory?( cache_dir )
		cached_time = nil
		cached_time = File::mtime( file_name ) if File::exist?( file_name )

		unless cached_time.nil?
			if Time.now > cached_time + cache_time
				update = true
			end
		end

		if cached_time.nil? or update
			begin
				Timeout.timeout(10) do
					open( "http://feeds.delicious.com/v2/json/urlinfo/#{url_md5}") do |file|
						File::open( file_name, 'wb' ) do |f|
							f.write( file.read )
						end
					end
				end
			rescue => e
				@logger.debug( e )
			end
		end
	rescue
	end

	begin
		File::open( file_name ) do |f|
				data = JSON.parse(@conf.to_native( f.read, 'utf-8' ))
			unless data[0].nil?
				count = data[0]["total_posts"].to_i
			end
		end
	rescue
	end

	if count > 0
		r << %Q| #{count} users</a>|
	else
		r << %Q|</a>|
	end

	return r
end

def add_yahoobm(date, index)
	r = " | "
	r << %Q|<a href="http://bookmarks.yahoo.co.jp/url?url=#{permalink(date, index)}&amp;opener=bm&amp;ei=UTF-8"><img src="http://i.yimg.jp/images/sicons/ybm16.gif" style="border: 0 none;vertical-align: middle;" title="#{@section_footer_yahoobm_label}" alt="#{@section_footer_yahoobm_label}" width="16" height="16" class="icon"></a>|
	return r
end

