#!/usr/bin/env ruby
# -*- coding: utf-8; -*-
# estraier-search.rb $Revision: 1.1.2.12 $
#
# Copyright (C) 2007 Kazuhiko <kazuhiko@fdiary.net>
# You can redistribute it and/or modify it under GPL2.
#
BEGIN { $stdout.binmode }
begin
	Encoding::default_external = 'UTF-8'
rescue NameError
	$KCODE = 'n'
end

require "estraierpure"
require "enumerator"
require "date"

if FileTest::symlink?( __FILE__ ) then
	org_path = File::dirname( File::readlink( __FILE__ ) )
else
	org_path = File::dirname( __FILE__ )
end
$:.unshift( org_path.untaint )
require 'tdiary'

#
# class TDiaryEstraier
#
module TDiary
	class TDiaryEstraier < ::TDiary::TDiaryBase
		MAX_PAGES = 20
		SORT_OPTIONS = [
			["score", "スコア順"],
			["date", "日付順"],
		]
		ORDER_OPTIONS = [
			["asc", "昇順"],
			["desc", "降順"],
		]
		FORM_OPTIONS = [
			["simple", "簡便書式"],
			["normal", "通常書式"],
		]
		NUM_OPTIONS = [10, 20, 30, 50, 100]

		def initialize( cgi, rhtml, conf )
			super
			@host = @conf["estraier.host"] || "localhost"
			@port = @conf["estraier.port"] || 1978
			@path = @conf["estraier.path"] || "/node/"
			@node = @conf["estraier.node"] || "tdiary"
			parse_args
			format_form
			if @query.empty?
				@msg = '検索条件を入力して、「検索」ボタンを押してください'
			else
				search
			end
		end

		def load_plugins
			super
			# add a opensearch rss link
			@plugin.instance_variable_get('@header_procs').unshift Proc.new {
				cgi_url = @conf.base_url.sub(%r|/[^/]*$|, '/') + (@cgi.script_name ? _(File.basename(@cgi.script_name)) : '')
				%Q|\t<link rel="alternate" type="application/rss+xml" title="Search Result RSS" href="#{cgi_url}#{format_anchor(@start, @num)};type=rss">\n|
			}
			# override some plugins
			def @plugin.sn(number = nil); ''; end
			def @plugin.whats_new; ''; end
		end

		def eval_rxml
			require 'time'
			load_plugins
			ERB::new( File::open( "#{PATH}/skel/estraier.rxml" ){|f| f.read }.untaint ).result( binding )
		end

		private

		def parse_args
			@query = @cgi["query"].strip
			@start = @cgi["start"].to_i
			@num = @cgi["num"].to_i
			if @num < 1
				@num = 10
			elsif @num > 100
				@num = 100
			end
			@sort = @cgi["sort"].empty? ? "score" : @cgi["sort"]
			@order = @cgi["order"].empty? ? "desc" : @cgi["order"]
			@form = @cgi["form"].empty? ? "simple" : @cgi["form"]
		end

		def search
			@db = EstraierPure::Node.new
			@db.set_url("http://#{@host}:#{@port}#{@path}#{@node}")
			begin
				t = Time.now
				cond = create_search_options
				cond.set_phrase(convert(@query))
				@result = @db.search(cond, 0)
				@secs = Time.now - t
			rescue
				@msg = "エラー: #{_($!.to_s + $@.join)}</p>"
			end
		end

		def format_result_item(item)
			@date = item.attr('@uri')
			if @conf["estraier.with_user_name"]
				@date.gsub!(/.*:/, "")
			end
			@date_str = Date.parse(@date).strftime(@conf.date_format)
			@last_modified = item.attr('@mdate')
			@title = _(item.attr('@title'))
			@summary = _(item.snippet).gsub(/\t.*/, "").gsub(/\n\n/, " ... ").delete("\n")
			for term in @query.split
				@title.gsub!(Regexp.new(Regexp.quote(CGI.escapeHTML(term)), true, @encoding), "<strong>\\&</strong>")
				@summary.gsub!(Regexp.new(Regexp.quote(CGI.escapeHTML(term)), true, @encoding), "<strong>\\&</strong>")
			end
			query = "[SIMILAR]"
			item.keywords.split(/\t/).each_slice(2).collect do |k, s|
				query << " WITH #{s} #{k}"
			end
			@similar = "%s?query=%s" %
				[_(@cgi.script_name || ""), CGI::escape(query)]
		end

		def format_links(result)
			page_count = (result.doc_num - 1) / @num + 1
			current_page = @start / @num + 1
			first_page = current_page - (MAX_PAGES / 2 - 1)
			if first_page < 1
				first_page = 1
			end
			last_page = first_page + MAX_PAGES - 1
			if last_page > page_count
				last_page = page_count
			end
			buf = "<p class=\"infobar\">\n"
			if current_page > 1
				buf.concat(format_link("前へ", @start - @num, @num))
			end
			if first_page > 1
				buf.concat("... ")
			end
			for i in first_page..last_page
				if i == current_page
					buf.concat("#{i} ")
				else
					buf.concat(format_link(i.to_s, (i - 1) * @num, @num))
				end
			end
			if last_page < page_count
				buf.concat("... ")
			end
			if current_page < page_count
				buf.concat(format_link("次へ", @start + @num, @num))
			end
			buf.concat("</p>\n")
			return buf
		end

		def format_anchor(start, num)
			return format('?query=%s;start=%d;num=%d;sort=%s;order=%s', CGI::escape(@query), start, num, _(@sort), _(@order))
		end

		def format_link(label, start, num)
			return format('<a href="%s%s">%s</a> ',	_(@cgi.script_name ? @cgi.script_name : ""),  format_anchor(start, num), _(label))
		end

		def create_search_options
			cond = EstraierPure::Condition.new
			if @conf["estraier.with_user_name"]
				cond.add_attr("@uri STRBW #{@conf.user_name}:")
			end
			if @sort == "date"
				order = "@uri"
			else
				order = ""
			end
			if @order == "asc"
				order = "[SCA]" if order.empty?
			else
				unless order.empty?
					order << " STRD"
				end
			end
			if @form == "simple"
				cond.set_options(EstraierPure::Condition::SIMPLE)
			end
			cond.set_order(order)
			return cond
		end

		def format_options(options, value)
			return options.collect { |val, label|
				if val == value
					"<option value=\"#{_(val)}\" selected>#{_(label)}</option>"
				else
					"<option value=\"#{_(val)}\">#{_(label)}</option>"
				end
			}.join("\n")
		end

		def format_form
			@num_options = NUM_OPTIONS.collect { |n|
				if n == @num
					"<option value=\"#{n}\" selected>#{n}件ずつ</option>"
				else
					"<option value=\"#{n}\">#{n}件ずつ</option>"
				end
			}.join("\n")
			@sort_options = format_options(SORT_OPTIONS, @sort)
			@order_options = format_options(ORDER_OPTIONS, @order)
			@form_options = format_options(FORM_OPTIONS, @form)
		end

		def _(str)
			CGI::escapeHTML(str)
		end

		def convert(str)
			@conf.to_native(str)
		end
	end
end

begin
	@cgi = CGI::new
	if ::TDiary::Config.instance_method(:initialize).arity != 0
		# for tDiary 2.1 or later
		conf = ::TDiary::Config::new(@cgi)
	else
		# for tDiary 2.0 or earlier
		conf = ::TDiary::Config::new
	end
	tdiary = TDiary::TDiaryEstraier::new( @cgi, 'estraier.rhtml', conf )

	head = {
		'type' => 'text/html',
		'Vary' => 'User-Agent'
	}
	if @cgi.mobile_agent? then
		body = conf.to_mobile( tdiary.eval_rhtml( 'i.' ) )
		head['charset'] = conf.mobile_encoding
		head['Content-Length'] = body.bytesize.to_s
	else
		if @cgi['type'] == 'rss'
			head['type'] = "application/xml; charset=#{conf.encoding}"
			body = tdiary.eval_rxml
		else
			body = tdiary.eval_rhtml
		end
		head['charset'] = conf.encoding
		head['Content-Length'] = body.bytesize.to_s
		head['Pragma'] = 'no-cache'
		head['Cache-Control'] = 'no-cache'
	end
	print @cgi.header( head )
	print body
rescue Exception
	if @cgi then
		print @cgi.header( 'type' => 'text/plain' )
	else
		print "Content-Type: text/plain\n\n"
	end
	puts "#$! (#{$!.class})"
	puts ""
	puts $@.join( "\n" )
end
