# section_footer2.rb $Revision 1.0 $
#
# Copyright (c) 2008 SHIBATA Hiroshi <h-sbt@nifty.com>
# You can redistribute it and/or modify it under GPL2.
#

require 'digest/md5'
require 'open-uri'
require 'timeout'
require 'yaml'
require "pathname"

def permalink( date, index, escape = true )
	ymd = date.strftime( "%Y%m%d" )
	uri = @conf.index.dup
	uri[0, 0] = @conf.base_url unless %r|^https?://|i =~ uri
	uri.gsub!( %r|/\./|, '/' )
	if escape then
		uri + CGI::escape(anchor( "#{ymd}p%02d" % index ))
	else
		uri + anchor( "#{ymd}p%02d" % index )
	end
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

	unless @conf.mobile_agent? then
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

		# 「このエントリを含む del.icio.us(json API)」
		r << add_delicious_json(date, index)

		# SBM アイコンの追加
		yaml_dir = "#{@cache_path}/yaml/"
		Dir.glob( yaml_dir + "*.yaml" ) do |file|
			r << parse_sbm_yaml(file, date, index)
		end

		# Permalinkの追加
		r << add_permalink(date, index)
	end

	r << "</div>\n"
end

def add_delicious_json(date, index)
	require 'json'
	
	url_md5 = Digest::MD5.hexdigest(permalink(date, index, false))
	cache_dir = "#{@cache_path}/delicious/#{date.strftime( "%Y%m" )}/"
	file_name = "#{cache_dir}/#{url_md5}.json"
	cache_time = 8 * 60 * 60  # 8 hour
	update = false
	count = 0

	r = " | "
	r << %Q|<a href="http://del.icio.us/url/#{url_md5}"><img src="http://images.del.icio.us/static/img/delicious.small.gif" width="10" height="10" style="border: none;vertical-align: middle;" alt="このエントリを含む del.icio.us" title="このエントリを含む del.icio.us">|

	begin
		Dir::mkdir( cache_dir ) unless File::directory?( cache_dir )
		cached_time = nil
		cached_time = File::mtime( file_name ) if File::exist?( file_name )

		unless cached_time.nil?
			if Time.now > cached_time + cache_time
				update = true
			end
		end

		if cached_time.nil? or update
			begin
				timeout(10) do
					open( 'http://badges.del.icio.us/feeds/json/url/data?hash=' + url_md5 ) do |file|
						File::open( file_name, 'wb' ) do |f|
							f.write( file.read )
						end
					end
				end
			rescue TimeoutError
			rescue
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
		r << %Q| #{count} users|
	end

	r << %Q|</a>|
	
	return r
end

def parse_sbm_yaml(file, date, index)
	config = YAML.load(Pathname.new(file).expand_path.read)

	r = " | "
	unless config.nil? then
		r << %Q|<a href="#{config["url"]}#{permalink(date, index)}")>|
		r << %Q|<img src="#{config["src"]}" style="border: none;vertical-align: middle;" |
		r << %Q|title="#{config["title"]}" |
		r << %Q|alt="#{config["title"]}" />|
		unless config["counter"].nil? then
			r << %Q| <img src="#{config["counter"]}#{permalink(date, index)}" style="border: none;vertical-align: middle;" />|
		end
		r << %Q|</a>|
	end

	return r
end

def add_permalink(date, index)
	r = " | "
	r << %Q|<a href="#{permalink(date, index, false)}">Permalink</a> |
	return r
end
