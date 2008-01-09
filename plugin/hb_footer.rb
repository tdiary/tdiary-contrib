#
# hb_footer.rb
#
# はてなブックマーク (http://b.hatena.ne.jp/) のコメントを該当日付に貼り付けるtDiaryプラグイン
# 改造版rss_recent Version 0.0.5i2と共に使用する
#
# Licence: GPL
# Author: ishinao <ishinao@ishinao.net>
#

add_body_leave_proc(Proc.new do |date|
  if @mode == 'day' or @mode == 'latest'
    diary = @diaries[date.strftime('%Y%m%d')]
    pnum = 1
    hbsrc = ''
    diary.each_section do |para|
      td_url = "http://tdiary.ishinao.net/#{date.strftime('%Y%m%d')}.html%23p#{'%02d' % pnum}"
      hb_url = "http://b.hatena.ne.jp/entry/#{td_url}"
      rss_url = "http://b.hatena.ne.jp/entry/rss/#{td_url}"

      template_head = %Q[<div class="section">\n<h3><a href="#{CGI.escapeHTML(hb_url)}">はてなブックマークの反応</a></h3>\n<ul class="hb_footer">\n]
      template_list = '<li><span class="date">#{time.strftime("%Y年%m月%d日")}</span> <span class="hatenaid"><a href="#{CGI.escapeHTML(url)}">#{CGI.escapeHTML(title)}</a></span> <span class="comment">#{CGI.escapeHTML(description.to_s)}</span></li>'
      template_foot = "</ul>\n</div>\n"

      cache_time = 3600;
      if date.strftime('%Y-%m-%d') != Time.now.strftime('%Y-%m-%d')
        cache_time = 3600 * 12;
      end
      hbsrc << hb_footer(rss_url, 50, cache_time, template_head, template_list, template_foot)
      pnum+=1
    end
    hbsrc
  else
    ''
  end
end)

# rss-recent.rb: RSS recent plugin 
#
# rss_recnet: show recnet list from RSS
#   parameters (default):
#      url: URL of RSS
#      max: max of list itmes(5)
#      cache_time: cache time(second) of RSS(60*60)
#      template_head: rendering header part
#      template_list: rendering RSS item part(with loop)
#      template_foot: rendering footer part
#
# Copyright (c) 2003-2004 Kouhei Sutou <kou@cozmixng.org>
# Distributed under the GPL
#
# Modified using template string and content:encoded
# Version 0.0.5i2 by ishinao <ishinao@ishinao.net>
#

require "rss/rss"

RSS_RECENT_FIELD_SEPARATOR = "\0"
RSS_RECENT_ENTRY_SEPARATOR = "\1"
RSS_RECENT_VERSION = "0.0.5i2"
RSS_RECENT_HTTP_HEADER = {
	"User-Agent" => "tDiary RSS recent plugin version #{RSS_RECENT_VERSION}. " <<
	"Using RSS parser version is #{::RSS::VERSION}.",
}

def hb_footer(url, max = 5, cache_time = 3600, \
	template_head = "<ul>\n", \
	template_list = '<li><span class="#{hb_footer_modified_class(time)}"><a href="#{CGI.escapeHTML(url)}" title="#{CGI.escapeHTML(title)}">#{CGI::escapeHTML(title)}</a></span></li>\n', \
	template_foot = "</ul>\n")
	url.untaint

	cache_file = "#{@cache_path}/rss-recent.#{CGI.escape(url)}"

	hb_footer_cache_rss(url, cache_file, cache_time.to_i)
	
	return '' unless test(?r, cache_file)

	rv = template_head
	
	i = 0
	hb_footer_read_from_cache(cache_file).each do |title, url, time, content, description|
		break if i >= max
		next if (url.nil? or title.nil?)
		rv << eval('%Q[' + template_list + ']')
		i += 1
	end

	rv << template_foot

	if i > 0
		rv
	else
		''
	end
end

class InvalidResourceError < StandardError; end

def hb_footer_cache_rss(url, cache_file, cache_time)

	cached_time = nil
	cached_time = File.mtime(cache_file) if File.exist?(cache_file)

	if cached_time.nil? or Time.now > cached_time + cache_time
		require 'time'
		require 'open-uri'
		require 'net/http'
		require 'uri/generic'
		require 'rss/parser'
		require 'rss/1.0'
		require 'rss/2.0'
		require 'rss/dublincore'
		require 'rss/content'
		
		begin
			uri = URI.parse(url)

			raise URI::InvalidURIError if uri.scheme != "http"

			rss_source = hb_footer_fetch_rss(uri, cached_time)
			
			raise InvalidResourceError if rss_source.nil?

			# parse RSS
			rss = ::RSS::Parser.parse(rss_source, false)
			raise ::RSS::Error if rss.nil?

			# pre processing
			begin
				rss.output_encoding = @conf.charset || charset
			rescue ::RSS::UnknownConversionMethodError
			end

			rss_infos = rss.items.collect do |item|
				hb_footer_pubDate_to_dc_date(item)
				[item.title, item.link, item.dc_date, item.content_encoded, item.description]
			end
			hb_footer_write_to_cache(cache_file, rss_infos)

		rescue URI::InvalidURIError
			hb_footer_write_to_cache(cache_file, [['Invalid URI', url]])
		rescue InvalidResourceError, ::RSS::Error
#			hb_footer_write_to_cache(cache_file, [['Invalid Resource', url]])
# when cannot get valid RSS, use old cache
		end
	end

end

def hb_footer_fetch_rss(uri, cache_time)
	rss = nil
	begin
		uri.open(hb_footer_http_header(cache_time)) do |f|
			case f.status.first
			when "200"
				rss = f.read
				# STDERR.puts "Got RSS of #{uri}"
			when "304"
				# not modified
				# STDERR.puts "#{uri} does not modified"
			else
				raise InvalidResourceError
			end
		end
	rescue TimeoutError, SocketError, StandardError,
			SecurityError # occured in redirect
		raise InvalidResourceError
	end
	rss
end

def hb_footer_http_header(cache_time)
	header = RSS_RECENT_HTTP_HEADER.dup
	if cache_time.respond_to?(:rfc2822)
		header["If-Modified-Since"] = cache_time.rfc2822
	end
	header
end

def hb_footer_write_to_cache(cache_file, rss_infos)
	File.open(cache_file, 'w') do |f|
		f.flock(File::LOCK_EX)
		rss_infos.each do |info|
			f << info.join(RSS_RECENT_FIELD_SEPARATOR)
			f << RSS_RECENT_ENTRY_SEPARATOR
		end
		f.flock(File::LOCK_UN)
	end
end

def hb_footer_read_from_cache(cache_file)
	require 'time'
	infos = []
	File.open(cache_file) do |f|
		while info = f.gets(RSS_RECENT_ENTRY_SEPARATOR)
			info = info.chomp(RSS_RECENT_ENTRY_SEPARATOR)
			infos << info.split(RSS_RECENT_FIELD_SEPARATOR)
		end
	end
	infos.collect do |title, url, time, content, description|
		[
			hb_footer_convert(title),
			hb_footer_convert(url),
			hb_footer_convert(time) {|time| Time.parse(time)},
			hb_footer_convert(content),
            hb_footer_convert(description),
		]
	end
end

def hb_footer_convert(str)
	if str.nil? or str.empty?
		nil
	else
		if block_given?
			yield str
		else
			str
		end
	end
end

# from RWiki
def hb_footer_modified(t)
	return '-' unless t
	dif = (Time.now - t).to_i
	dif = dif / 60
	return "#{dif}m" if dif <= 60
	dif = dif / 60
	return "#{dif}h" if dif <= 24
	dif = dif / 24
	return "#{dif}d"
end

# from RWiki
def hb_footer_modified_class(t)
	return 'dangling' unless t
	dif = (Time.now - t).to_i
	dif = dif / 60
	return "modified-hour" if dif <= 60
	dif = dif / 60
	return "modified-today" if dif <= 24
	dif = dif / 24
	return "modified-month" if dif <= 30
	return "modified-year" if dif <= 365
	return "modified-old"
end

def hb_footer_pubDate_to_dc_date(target)
	if target.respond_to?(:pubDate)
		class << target
			alias_method(:dc_date, :pubDate)
		end
	end
end
