#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# rast-search.rb $Revision: 1.6.2.2 $
#
# Copyright (C) 2005 Kazuhiko <kazuhiko@fdiary.net>
# You can redistribute it and/or modify it under GPL2.
#
$KCODE= 'u'
BEGIN { $stdout.binmode }

if FileTest::symlink?( __FILE__ ) then
	org_path = File::dirname( File::readlink( __FILE__ ) )
else
	org_path = File::dirname( __FILE__ )
end
$:.unshift( org_path.untaint )
require 'tdiary'
require 'rast'

#
# class TDiaryRast
#
module TDiary
	class TDiaryRast < ::TDiary::TDiaryBase
		MAX_PAGES = 20
		SORT_OPTIONS = [
			["score", "スコア順"],
			["date", "日付順"],
		]
		SORT_PROPERTIES = ["date"]
		ORDER_OPTIONS = [
			["asc", "昇順"],
			["desc", "降順"],
		]
		NUM_OPTIONS = [10, 20, 30, 50, 100]

		def initialize( cgi, rhtml, conf )
			super
			@db_path = conf.options['rast.db_path'] || "#{cache_path}/rast"
			@encoding = 'utf8'
			# conf.options['sp.selected'] = ''
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
		end

		def eval_rxml
			require 'time'
			load_plugins
			ERB::new( File::open( "#{PATH}/skel/rast.rxml" ){|f| f.read }.untaint ).result( binding )
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
		end

		def search
			db = Rast::DB.open(@db_path, Rast::DB::RDONLY)
			begin
				options = create_search_options
				t = Time.now
				@result = db.search(convert(@query), options)
				@secs = Time.now - t
			rescue
				@msg = "エラー: #{_($!.to_s)}</p>"
			ensure
				db.close
			end
		end

		def format_result_item(item)
			if @conf['rast.with_user_name']
				@title, @user, @date, @last_modified = *item.properties
			else
				@title, @date, @last_modified = *item.properties
			end
			@summary = _(item.summary) || ''
			for term in @result.terms
				@summary.gsub!(Regexp.new(Regexp.quote(CGI.escapeHTML(term.term)), true, @encoding), "<strong>\\&</strong>")
			end
		end

		def format_links(result)
			page_count = (result.hit_count - 1) / @num + 1
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
			options = {
				"properties" => [
					"title", "date", 'last_modified'
				],
				"need_summary" => true,
				"summary_nchars" => 150,
				"start_no" => @start,
				"num_items" => @num
			}
			options['properties'] << 'user' if @conf['rast.with_user_name']
			if SORT_PROPERTIES.include?(@sort)
				options["sort_method"] = Rast::SORT_METHOD_PROPERTY
				options["sort_property"] = @sort
			end
			if @order == "asc"
				options["sort_order"] = Rast::SORT_ORDER_ASCENDING
			else
				options["sort_order"] = Rast::SORT_ORDER_DESCENDING
			end
			return options
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
	tdiary = TDiary::TDiaryRast::new( @cgi, 'rast.rhtml', conf )

	head = {
		'type' => 'text/html',
		'Vary' => 'User-Agent'
	}
	if @cgi.mobile_agent? then
		body = conf.to_mobile( tdiary.eval_rhtml( 'i.' ) )
		head['charset'] = conf.mobile_encoding
		head['Content-Length'] = body.size.to_s
	else
		if @cgi['type'] == 'rss'
			head['type'] = "application/xml; charset=#{conf.encoding}"
			body = tdiary.eval_rxml
		else
			body = tdiary.eval_rhtml
		end
		head['charset'] = conf.encoding
		head['Content-Length'] = body.size.to_s
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
