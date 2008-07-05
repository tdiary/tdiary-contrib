# section_footer2.rb $Revision 1.0 $
#
# Copyright (c) 2008 SHIBATA Hiroshi <h-sbt@nifty.com>
# You can redistribute it and/or modify it under GPL2.
#

require 'digest/md5'
require 'json/ext'
require 'timeout'
require 'open-uri'
require 'yaml'
require 'pathname'

def permalink( date, index, escape = true )
	ymd = date.strftime( "%Y%m%d" )
	uri = @conf.index.dup
	uri[0, 0] = @conf.base_url unless %r|^https?://|i =~ uri
	uri.gsub!( %r|/\./|, '/' )
	if escape 
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
		s = subtitle.sub( /^(?:\[[^\[]+?\])+/ ) do
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
	unless @conf.mobile_agent? or bot? then
		# add category_tag
		if @category_to_tag_list and not @category_to_tag_list.empty? then
			r << "Tags: "
			@category_to_tag_list.each do |tag, blog|
				r << category_anchor( "#{tag}" ).sub( /^\[/, '' ).sub( /\]$/, '' ) << ' '
			end
			r << ' | '
		end
		
		# add del.icio.us link
		r << add_delicious(date, index)

		# add SBM link
		yaml_dir = "#{@cache_path}/yaml/"
		Dir.glob( yaml_dir + "*.yaml" ) do |file|
			r << parse_sbm_yaml(file, date, index)
		end

		# add Permalink
		r << %Q|<a href="#{permalink(date, index, false)}">Permalink</a> |
	end
	r << "</div>\n"
end

def call_delicious_json( url_md5 )
	json = nil
	begin
		timeout(5) do
			open( "http://badges.del.icio.us/feeds/json/url/data?hash=#{url_md5}" ) do |f|
				json = JSON.parse( f.read )
			end
		end
	rescue => e
		@conf.debug( e )
	end
	return json
end

def add_delicious( date, index )
	url_md5 = Digest::MD5.hexdigest(permalink(date, index, false))
	db_file = "#{@cache_path}/delicious.cache"

	r = ''
	r << %Q|<a href="http://del.icio.us/url/#{url_md5}"><img src="http://images.del.icio.us/static/img/delicious.small.gif" style="border: none;vertical-align: middle;" alt="#{@section_footer2_delicious_label}" title="#{@section_footer2_delicious_label}">|

	begin
		cache_time = 8 * 60 * 60  # 12 hour

		PStore.new(db_file).transaction do |db|
			entry = db[url_md5]
			entry = { :count => 0, :update=> Time.at(0) } if entry.nil?
			
			if Time.now > entry[:update] + cache_time
				json = call_delicious_json( url_md5 )
				entry[:count] = json[0]["total_posts"].to_i unless json[0].nil?
				entry[:update] = Time.now
				db[url_md5] = entry
			end

			if entry[:count] > 0
				r << %Q| #{entry[:count]} user|
				r << 's' if entry[:count] > 1
			end
		end
	rescue => e
		@conf.debug( e )
	end

	r << '</a>'
	r << ' | '

	return r
end

def parse_sbm_yaml(file, date, index)
	config = YAML.load( Pathname.new( file ).expand_path.read )
	r = ""

	unless config.nil?
		title = config["title"][@conf.lang]
		r << %Q|<a href="#{config["url"]}#{permalink(date, index)}">|
		r << %Q|<img src="#{config["src"]}" style="border: none;vertical-align: middle;" |
		r << %Q|title="#{title}" |
		r << %Q|alt="#{title}" />|
		r << %Q| <img src="#{config["counter"]}#{permalink(date, index)}" style="border: none;vertical-align: middle;" />| unless config["counter"].nil?
		r << '</a>'
		r << ' | '
	end

	return r
end
