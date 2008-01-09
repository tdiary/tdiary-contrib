#
# mm_footer.rb
#
# MM ( http://1470.net/mm/) のmylistを各日付に貼り付けるtDiaryプラグイン
#
# Licence: GPL
# Author: ishinao <ishinao@ishinao.net>
#

require 'nkf'

add_body_leave_proc(Proc.new do |date|

  oldest_date = Time.local(2005, 1, 11)
  if date > oldest_date
	 if @mode == 'day' or @mode == 'latest'
		if date < Time.local(2006, 7, 6)
			mm_user = 82	# your MM id
			url = "http://1470.net/mm/mylist.html/#{mm_user}?date=#{date.strftime('%Y-%m-%d')}"
			rssurl = "http://1470.net/mm/mylist.html/#{mm_user}?date=#{date.strftime('%Y-%m-%d')}&mode=rss"
			template_list = '<li>#{content}</li>'
		else
			userName = 'hsbt' # your 1470.net id
			url = "http://1470.net/user/#{userName}/#{date.strftime('%Y/%m/%d')}"
			rssurl = "http://1470.net/user/#{userName}/#{date.strftime('%Y/%m/%d')}/feed"
			template_list = '<li>#{content.gsub(/href="\//, "href=\"http://1470.net\/")}</li>'
		end

		template_head = %Q[<div class="section mm_footer">\n<h3><a href="#{CGI.escapeHTML(url)}">今日のメモ</a> powered by <a href="http://1470.net/">1470.net</a></h3>\n<ul class="mm_footer">\n]
		template_foot = "</ul>\n</div>\n"

		cache_time = 3600;
		if date.strftime('%Y-%m-%d') != Time.now.strftime('%Y-%m-%d')
		  cache_time = 3600 * 12;
		end
		NKF.nkf('-e', mm_footer(rssurl, 50, cache_time, template_head, template_list, template_foot))
	 else
		''
	 end
  end
end)

require "rss/rss"

MM_FOOTER_FIELD_SEPARATOR = "\0"
MM_FOOTER_ENTRY_SEPARATOR = "\1"
MM_FOOTER_VERSION = "0.0.5i"
MM_FOOTER_HTTP_HEADER = {
	"User-Agent" => "tDiary RSS recent plugin version #{MM_FOOTER_VERSION}. " <<
	"Using RSS parser version is #{::RSS::VERSION}.",
}

def mm_footer(url, max = 5, cache_time = 3600, \
	template_head = "<ul>\n", \
	template_list = '<li><span class="#{mm_footer_modified_class(time)}"><a href="#{CGI.escapeHTML(url)}" title="#{CGI.escapeHTML(title)}">#{CGI::escapeHTML(title)}</a></span></li>\n', \
	template_foot = "</ul>\n")
	url.untaint

	cache_file = "#{@cache_path}/rss-recent/rss-recent.#{CGI.escape(url)}"

	mm_footer_cache_rss(url, cache_file, cache_time.to_i)

	return '' unless test(?r, cache_file)

	rv = template_head

	i = 0
	mm_footer_read_from_cache(cache_file).each do |title, url, time, content|
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

def mm_footer_cache_rss(url, cache_file, cache_time)

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

			rss_source = mm_footer_fetch_rss(uri, cached_time)

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
				mm_footer_pubDate_to_dc_date(item)
				[item.title, item.link, item.dc_date, item.content_encoded]
			end
			mm_footer_write_to_cache(cache_file, rss_infos)

		rescue URI::InvalidURIError
			mm_footer_write_to_cache(cache_file, [['Invalid URI', url]])
		rescue InvalidResourceError, ::RSS::Error
#			mm_footer_write_to_cache(cache_file, [['Invalid Resource', url]])
# when cannot get valid RSS, use old cache
		end
	end

end

def mm_footer_fetch_rss(uri, cache_time)
	rss = nil
	begin
		uri.open(mm_footer_http_header(cache_time)) do |f|
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

def mm_footer_http_header(cache_time)
	header = MM_FOOTER_HTTP_HEADER.dup
	if cache_time.respond_to?(:rfc2822)
		header["If-Modified-Since"] = cache_time.rfc2822
	end
	header
end

def mm_footer_write_to_cache(cache_file, rss_infos)
	File.open(cache_file, 'w') do |f|
		f.flock(File::LOCK_EX)
		rss_infos.each do |info|
			f << info.join(MM_FOOTER_FIELD_SEPARATOR)
			f << MM_FOOTER_ENTRY_SEPARATOR
		end
		f.flock(File::LOCK_UN)
	end
end

def mm_footer_read_from_cache(cache_file)
	require 'time'
	infos = []
	File.open(cache_file) do |f|
		while info = f.gets(MM_FOOTER_ENTRY_SEPARATOR)
			info = info.chomp(MM_FOOTER_ENTRY_SEPARATOR)
			infos << info.split(MM_FOOTER_FIELD_SEPARATOR)
		end
	end
	infos.collect do |title, url, time, content|
		[
			mm_footer_convert(title),
			mm_footer_convert(url),
			mm_footer_convert(time) {|time| Time.parse(time)},
			mm_footer_convert(content)
		]
	end
end

def mm_footer_convert(str)
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

def mm_footer_pubDate_to_dc_date(target)
	if target.respond_to?(:pubDate)
		class << target
			alias_method(:dc_date, :pubDate)
		end
	end
end
