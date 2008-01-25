# Copyright (C) 2007, KURODA Hiraku <hiraku@hinet.mydns.jp>
# You can redistribute it and/or modify it under GPL2. 

require "bayes"

module TDiary::Filter
	class SpambayesFilter < Filter
		class TokenList < Bayes::TokenList
			def initialize
				super(Bayes::CHARSET::EUC)
			end
		end

		module Misc
			@@without_filtering = nil
			@@force_filtering = nil
			def without_filtering?
				@@without_filtering || (@conf[conf_use]||"").size==0
			end
			def without_filtering
				orig = @@without_filtering
				@@without_filtering = true
				yield
			ensure
				@@without_filtering = orig
			end
			def force_filtering?; @@force_filtering; end
			def force_filtering
				orig = @@force_filtering
				@@force_filtering = true
				yield
			ensure
				@@force_filtering = orig
			end

			@@conf = nil
			def self.conf=(conf)
				@@conf ||= conf
			end
			def self.conf; @@conf; end
			def self.to_native(s)
				s ? @@conf.to_native(CGI.unescape(s)).gsub(/[\x00-\x20]/, " ") : ""
			end

			PREFIX = "spambayes"
			def conf_filter; "#{PREFIX}.filter"; end
			def conf_mail; "#{PREFIX}.mail"; end
			def conf_threshold; "#{PREFIX}.threshold"; end
			def conf_use; "#{PREFIX}.use"; end
			def conf_log; "#{PREFIX}.log"; end
			def conf_for_referer; "#{PREFIX}.for_referer"; end

			def cache_path
				@conf.cache_path || "#{@conf.data_path}cache"
			end

			def bayes_cache
				Dir.mkdir(cache_path) unless File.exist?(cache_path)
				r = "#{cache_path}/bayes"
				Dir.mkdir(r) unless File.exist?(r)
				r
			end

			def referer_cache(key)
				"#{bayes_cache}/referer_#{key}.log"
			end

			def referer_corpus
				"#{corpus_path}/referer.db"
			end

			def unescape_referer(referer)
				@conf.to_native(CGI.unescape(referer)).gsub(/[\x00-\x20]+/, " ")
			end

			def debug_log
				"#{bayes_cache}/debug.log"
			end

			def debug(*args)
				open(debug_log, "a") do |f|
					f.puts(*args)
				end
			end

			def corpus_path
				r = "#{bayes_cache}/corpus"
				Dir.mkdir(r) unless File.exist?(r)
				r
			end

			def bayes_db
				 "#{@conf.data_path}/bayes.db"
			end

			def bayes_filter(reset=false)
				if reset
					@bayes_filter = nil
					File.delete(bayes_db) if File.exist?(bayes_db)
				end

				case @conf[conf_filter]
				when /graham/i
					@bayes_filter ||= Bayes::PaulGraham.new(bayes_db)
				else
					@bayes_filter ||= Bayes::PlainBayes.new(bayes_db)
				end
				@bayes_filter
			end

			def threshold
				(@conf[conf_threshold]||"0.95").to_f
			end

			def url(path=nil)
				if /^https?:\/\// =~ (path||"")
					path
				else
					"#{@conf.base_url[/^(.*?)\/?$/, 1]}/#{path||""}"
				end
			end

			def index_url
				url(@conf.index)
			end

			def update_url
				url(@conf.update)
			end
		end

		class Comment
			attr_reader :name, :date, :mail, :body, :remote_addr, :diary_date

			def self.load(file_name)
				r = nil
				open(file_name) do |f|
					f.flock(File::LOCK_SH)
					r = Marshal.load(f)
				end
				raise "NoData" unless r.is_a?(self)
				r
			end

			def initialize(comment, cgi)
				@name = comment.name || ""
				@date = comment.date || Time.now
				@mail = comment.mail || ""
				@body = comment.body || ""
				@remote_addr = cgi.remote_addr || ""
				d = cgi.params['date'][0] || Time.now.strftime("%Y%m%d")
				@diary_date = Time::local(*d.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]) + 12*60*60
			end

			def digest
				Digest::MD5.hexdigest([@name, @date, @mail, @body, @remote_addr, @diary_date].join)
			end

			RE_URL = %r[(?:https?|ftp)://[a-zA-Z0-9;/?:@&=+$,\-_.!~*\'()%]+]
			def token
				r = TokenList.new

				if @name.empty?
					r.push("", "N")
				else
					r.add_message(@name, "N")
				end
				r.add_mail_addr(@mail, "M")
				b = @body.dup
				b.gsub!(RE_URL) do |m|
					r.add_url(m, "U")
					""
				end
				r.add_message(b)
				r.add_host(@remote_addr, "A")

				r
			end

			def cache_name
				@date.strftime("%Y%m%d%H%M%S")+digest
			end
		end

		class Referer
			@@specials = {}

			def self.load_list(f)
				r = []
				open(f) do |f|
					f.flock(File::LOCK_SH)
					r << Marshal.load(f) until f.eof?
				end
				r
			rescue
				[]
			end

			def self.truncate_list(fn, size)
				return unless File.exist?(fn)
				open(fn, "a+") do |f|
					f.flock(File::LOCK_EX)

					buff = []
					buff << Marshal.load(f) until f.eof?

					buff.slice!(0, size)
					f.truncate(0)
					buff.each do |i|
						Marshal.dump(i, f)
					end
				end
			end

			def self.from_link(link)
				if /^(.*?)_(.*)$/=~link
					addr = $1
					url = $2
					new(CGI.unescape(url), addr ? CGI.unescape(addr) : nil)
				end
			end

			def self.from_html(html)
				if /^(.*?)_(.*)$/=~html
					addr = $1
					url = $2
					new(CGI.unescapeHTML(url), addr ? CGI.unescapeHTML(addr) : nil)
				end
			end

			attr_reader :referer, :remote_addr
			def initialize(referer, remote_addr = nil)
				@referer = referer
				@remote_addr = remote_addr
			end

			def hash
				@referer.hash
			end

			def eql?(dst)
				(self.class == dst.class) and (@referer == dst.referer)
			end

			def to_s
				Misc.to_native(@referer)
			end

			def to_html
				CGI.escapeHTML(@remote_addr||"") + "_" + CGI.escapeHTML(@referer)
			end

			def to_link
				CGI.escape(@remote_addr||"") + "_" + CGI.escape(@referer)
			end

			def <=>(o)
				to_s <=> o.to_s
			end

			def split_url
				base, request, anchor = @referer.scan(/^(.*?)(?:\?(.*?)(?:\#(.*))?)?$/)[0]
			end

			def token
				if l=special?
					m = l+"_token"
					if respond_to?(m)
						r = send(m)
					else
						r = special_token(@@specials[l])
					end
				else
					r = TokenList.new

					base, request, anchor = split_url
					r.add_url(base, "R")
					r.add_message(Misc.to_native(request)) if request
					r.add_message(Misc.to_native(anchor)) if anchor
				end

				r.add_host(@remote_addr, "A") if @remote_addr
				r
			end

			def viewable_html
				if l=special?
					m = l+"_html"
					if respond_to?(m)
						r = send(m)
					else
						r = special_html(@@specials[l])
					end
				else
					r = to_s
				end
				CGI.escapeHTML(r||"")
			end

			def special?
				r = @@specials.find do |n, a|
					a[0] =~ @referer
				end
				r ? r[0] : false
			end

			def self.special(name, regexp, label = nil)
				name = name.to_s
				label ||= name.capitalize
				@@specials[name.to_s] = [regexp, label]
			end

			def special_html(special)
				re, label = special
				"#{label}: " + Misc.to_native(@referer[re, 1])
			end

			def special_token(special)
				re = special[0]
				r = TokenList.new
				r.add_message(Misc.to_native(@referer[re, 1]))
				r
			end

			RE_QUERY_SEP = /[&;]|$/
			RE_QUERY_HEAD = /\?(?:.*#{RE_QUERY_SEP})?/o

			RE_GOOGLE_HOSTS = /.*\.google\.(?:(?:co\.)?[a-z]{2}|com(?:\.[a-z]{2})?)/o
			RE_GOOGLE = %r[^https?://#{RE_GOOGLE_HOSTS}/.*#{RE_QUERY_HEAD}(?:as_)?q=(.*?)#{RE_QUERY_SEP}]o
			special :google, RE_GOOGLE

			RE_GOOGLE_IP = /209\.85\.\d{3}\.\d{1,3}|72\.14\.\d{3}\.\d{1,3}/
			RE_GOOGLE_CACHE = %r[^https?://#{RE_GOOGLE_IP}/search#{RE_QUERY_HEAD}q=cache:[^:]+:(.*?)(?:(?:\+|\s+)(.*?))?#{RE_QUERY_SEP}]o
			special :google_cache, RE_GOOGLE_CACHE
			def google_cache_token
				r = TokenList.new
				RE_GOOGLE_CACHE =~ @referer
				ref = "http://#{CGI.unescape($1)}"
				words = $2
				r.add_url(ref, "R")
				r.add_message(Misc.to_native(words))
			end

			def google_cache_html	
				RE_GOOGLE_CACHE =~ @referer
				ref = "http://#{CGI.unescape($1)}"
				words = $2
				"Google(Cache): #{ref} #{Misc.to_native(words)}"
			end

			RE_EZ_GOOGLE = %r[^https?://ezsch\.ezweb\.ne\.jp/search/ezGoogleMain\.php#{RE_QUERY_HEAD}query=(.*?)#{RE_QUERY_SEP}]o
			special :ez_google, RE_EZ_GOOGLE, "Google(ezweb)"

			RE_EZWEB = %r[^https?://ezsch\.ezweb\.ne\.jp/.*?#{RE_QUERY_HEAD}query=(.*?)#{RE_QUERY_SEP}]
			special :ezweb, RE_EZWEB, "EZweb"

			RE_GOO = %r[^http://search\.goo\.ne\.jp/.*?#{RE_QUERY_HEAD}MT=(.*?)#{RE_QUERY_SEP}]o
			special :goo, RE_GOO

			RE_NIFTY = %r[^https?://search\.nifty\.com/.*?#{RE_QUERY_HEAD}Text=(.*?)#{RE_QUERY_SEP}]o
			special :nifty, RE_NIFTY

			RE_LIVESEARCH = %r[^https?://search\.live\.com/.*?#{RE_QUERY_HEAD}q=(.*?)#{RE_QUERY_SEP}]o
			special :livesearch, RE_LIVESEARCH, "Live Search"

			RE_BIGLOBE = %r[^https?://.*search\.biglobe\.ne\.jp/.*?#{RE_QUERY_HEAD}q=(.*?)#{RE_QUERY_SEP}]o
			special :biglobe, RE_BIGLOBE

			RE_MSN = %r[^https?://search\.msn\.co\.jp/.*?#{RE_QUERY_HEAD}q=(.*?)#{RE_QUERY_SEP}]o
			special :msn, RE_MSN, "MSN"

			RE_INFOSEEK = %r[^https?://search\.www\.infoseek\.co\.jp/.*?#{RE_QUERY_HEAD}qt=(.*?)#{RE_QUERY_SEP}]o
			special :infoseek, RE_INFOSEEK

			RE_HATENA_B = %r[^https?://b\.hatena\.ne\.jp/[^/]+/(.*?)(?:\?.*)?$]o
			special :hatena_b, RE_HATENA_B, "Hatena::Bookmark"

			RE_YAHOO = %r[^https?://.*\.yahoo\.co(?:m|\.[a-z]{2})/.*?#{RE_QUERY_HEAD}p=(.*?)#{RE_QUERY_SEP}]o
			special :yahoo, RE_YAHOO

			RE_BAIDU = %r[^https?://.*\.baidu\.jp/.*?#{RE_QUERY_HEAD}wd=(.*?)#{RE_QUERY_SEP}]o
			special :baidu, RE_BAIDU
		end

		include Misc

		def initialize( cgi, conf )
			super

			Misc.conf = conf
		end

		def comment_filter(diary, comment)
			return false if force_filtering?
			return true if without_filtering?
			r = true
			data = Comment.new(comment, @cgi)

			base_url = "#{update_url}?conf=spambayes;mode=conf;sb_mode="
			spam_url = "Register as spam : #{base_url}confirm_spam"
			ham_url = "Register as ham : #{base_url}confirm_ham"

			e = bayes_filter.estimate(data.token)
			case
			when e == nil
				r = false
				tag = "DOUBT"
				url = "#{spam_url}\n#{ham_url}"
			when e>threshold
				r = false
				tag = "SPAM"
				url = ham_url
			else
				r = true
				tag = "HAM"
				url = spam_url
			end
			cn = tag[0,1]+data.cache_name
			open("#{bayes_cache}/#{cn}", "w") do |f|
				f.flock(File::LOCK_SH)
				f.rewind
				Marshal.dump(data, f)
			end
			url.gsub!(/(\n|\z)/){";comment_id=#{cn}#$1"}

			require "socket"
			require "time"
			subject = "#{tag}:#{data.body.gsub(/\n/, " ")}".scan(/.{1,8}/e).map{|b| @conf.to_mail(b)}
			subject = subject.map{|i| "=?ISO-2022-JP?B?"+[i].pack("m").chomp+"?="}.join("\n ")
			addr = @conf[conf_mail]
			body = <<EOT
From: BayesFilter <#{addr}>
To: #{addr}
Date: #{Time.now.rfc2822}
Message-Id: <bayesfilter_#{cn}@#{Socket::gethostname}>
Subject: #{subject}
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Errors-To: #{addr}
X-Mailer: tDiary #{TDIARY_VERSION}
X-URL: http://www.tdiary.org/

Filter treated comment as #{tag}.
#{url}
----
Target: #{index_url}/?date=#{data.diary_date.strftime("%Y%m%d")}
Name: #{data.name}
Mail: #{data.mail}
IP : #{data.remote_addr}
Body:------
#{data.body.scan(/.{1,40}/).map{|l| @conf.to_mail(l)}.join("\n")}
EOT
			begin
				plugin = TDiary::Plugin.new("conf"=>@conf, "mode"=>"comment", "diaries"=>nil, "cgi"=>@cgi, "years"=>nil, "cache_path"=>cache_path, "date"=>data.diary_date, "comment"=>comment, "last_modified"=>nil)
				plugin.comment_mail(body, addr) if /^.*@.*/ =~ addr
			rescue ArgumentError
			end
			r
		rescue Exception => e
			debug "---- comment_filter ----", Time.now, e.message, e.class.name, e.backtrace.join("\n")
			r
		end

		def referer_filter(referer)
			return true if without_filtering? || !(@conf[conf_for_referer])
			r = true
			referer = Referer.new(referer, ENV["REMOTE_ADDR"])
			token = referer.token
			e = bayes_filter.estimate(token)
			case
			when e==nil
				r = false
				key = "doubt"
			when e>threshold
				r = false
				key = "spam"
			else
				key = "ham"
			end
			open(referer_cache(key), "a") do |f|
				f.flock(File::LOCK_SH)
				Marshal.dump(referer, f)
			end
			r
		rescue Exception => e
			debug "---- referer_filter ----", Time.now, e.message, e.class.name, e.backtrace.join("\n")
			raise
		end
	end
end
