# section_footer2.rb
#
# Copyright (c) 2008 SHIBATA Hiroshi <shibata.hiroshi@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#

require 'digest/md5'
require 'timeout'
require 'open-uri'
require 'yaml'
require 'pathname'

begin
	require 'json'
rescue
	retry if require 'rubygems'
end

def permalink( date, index, escape = true )
	ymd = date.strftime( "%Y%m%d" )
	uri = @conf.index.dup
	uri.sub!( %r|\A(?!https?://)|i, @conf.base_url )
	uri.gsub!( %r|/\.(?=/)|, "" ) # /././ -> /
	link = uri + anchor( "#{ymd}p%02d" % index )
	link.sub!( "#", "%23" ) if escape
	link
end

unless defined?(subtitle)
	def subtitle( date, index, escape = true )
		diary = @diaries[date.strftime( "%Y%m%d" )]
		return "" unless diary
		sn = 1
		diary.each_section do |section|
			if sn == index
				old_apply_plugin = @options["apply_plugin"]
				@options["apply_plugin"] = true
				title = apply_plugin( section.subtitle_to_html, true )
				@options["apply_plugin"] = old_apply_plugin
				title.gsub!( /(?=")/, "\\" ) if escape
				return title
			end
			sn += 1
		end
		''
	end
end

add_header_proc do
  <<-"EOS"
  <script src="http://platform.twitter.com/widgets.js" type="text/javascript"></script>
  <style type="text/css">iframe.twitter-share-button.twitter-count-horizontal {margin-bottom: -6px; }</style>
  <script src="http://connect.facebook.net/en_US/all.js"></script>
  <script>
  FB.init({
    appId  : '',
    status : true, // check login status
    cookie : true, // enable cookies to allow the server to access the session
    xfbml  : true  // parse XFBML
  });
  </script>
  EOS
end

add_section_enter_proc do |date, index|
	@category_to_tag_list = {}
	''
end

alias section_footer2_subtitle_link_original subtitle_link unless defined?( section_footer2_subtitle_link_original )
def subtitle_link( date, index, subtitle )
	s = ''
	@subtitle = subtitle
	if subtitle then
		s = subtitle.sub( /^(?:\[[^\[]+?\])+/ ) do
			$&.scan( /\[(.*?)\]/ ) do |tag|
				@category_to_tag_list[tag.shift] = false # false when diary
			end
			''
		end
	end
	section_footer2_subtitle_link_original( date, index, s.strip )
end

add_section_leave_proc do |date, index|
	unless @conf.mobile_agent? or @conf.iphone? or feed? or bot?
		r = '<div class="tags">'
		# add category_tag
		if @category_to_tag_list and not @category_to_tag_list.empty? then
			r << "Tags: "
			@category_to_tag_list.each do |tag, blog|
				r << category_anchor( "#{tag}" ).sub( /^\[/, '' ).sub( /\]$/, '' ) << ' '
			end
			r << ' | '
		end

		# add Delicious link
		r << add_delicious(date, index)

		# add SBM link
		yaml_dir = "#{@cache_path}/yaml/"
		Dir.glob( yaml_dir + "*.yaml" ) do |file|
			r << parse_sbm_yaml(file, date, index)
		end

		# add Facebook Like!
		r << %Q|<fb:like href="#{permalink(date, index, false)}" layout="button_count"></fb:like>|

		# add Twitter link
		r << add_twitter(date, index)

		# add Permalink
		r << %Q|<a href="#{permalink(date, index, false)}">Permalink</a> |

		r << "</div>\n"
	end
end

def call_delicious_json( url_md5 )
	json = nil
	begin
		timeout(10) do
			open( "http://feeds.delicious.com/v2/json/urlinfo/#{url_md5}" ) do |f|
				json = JSON.parse( f.read )
			end
		end
	rescue => e
		@logger.debug( e )
	end
	return json
end

def add_delicious( date, index )
	url_md5 = Digest::MD5.hexdigest(permalink(date, index, false))
	db_file = "#{@cache_path}/delicious.cache"

	r = ''
	r << %Q|<a href="http://delicious.com/url/#{url_md5}"><img src="http://static.delicious.com/img/delicious.small.gif" style="border: none;vertical-align: middle;" alt="#{@section_footer2_delicious_label}" title="#{@section_footer2_delicious_label}">|

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
		@logger.debug( e )
	end

	r << '</a>'
	r << ' | '

	return r
end

def add_twitter(date, index)
	r = <<-"EOS"
	<a href="http://twitter.com/share" class="twitter-share-button"
		data-url="#{permalink(date, index, false).gsub(/#.*$/, '')}"
		data-text="#{CGI.escapeHTML(subtitle(date, index))}"
		data-via="#{@conf['twitter.user']}"
	>tweet</a> | 
	EOS
end

def parse_sbm_yaml(file, date, index)
	config = YAML.load( Pathname.new( file ).expand_path.read )
	r = ""

	unless config.nil?

		url = config["url"]
		unless config['usesubtitle'].nil?
			sub = (@subtitle || '').sub( /\A(?:\[[^\]]*\])+ */, '' )
			sub = apply_plugin( sub, true ).strip
			regexp = config["usesubtitle"]
			url.gsub!(regexp, sub)
			char_space = ' '
		end

		title = config["title"][@conf.lang]
		r << %Q|<a href="#{url}#{char_space}#{permalink(date, index)}">|
		r << %Q|<img src="#{config["src"]}" style="border: none;vertical-align: middle;" |
		r << %Q|title="#{title}" |
		r << %Q|alt="#{title}">|
		r << %Q| <img src="#{config["counter"]}#{permalink(date, index)}" style="border: none;vertical-align: middle;">| unless config["counter"].nil?
		r << '</a>'
		r << ' | '
	end

	return r
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
