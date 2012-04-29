#!/usr/bin/env ruby
#
# Copyright (C) 2005 Kazuhiko <kazuhiko@fdiary.net>
# You can redistribute it and/or modify it under GPL2.
#

mode = ""
if $0 == __FILE__
	require 'cgi'
	ARGV << '' # dummy argument against cgi.rb offline mode.
	@cgi = CGI::new
	mode = "CMD"
else
	mode = "PLUGIN"
end

if mode == "CMD"
	tdiary_path = "."
	tdiary_conf = "."
	$stdout.sync = true

	def usage
		puts "rast-register.rb $Revision: 1.10.2.2 $"
		puts " register to rast index files from tDiary's database."
		puts " usage: ruby rast-regiser.rb [-p <tDiary directory>] [-c <tdiary.conf directory>]"
		exit
	end

	require 'getoptlong'
	parser = GetoptLong::new
	parser.set_options(['--path', '-p', GetoptLong::REQUIRED_ARGUMENT], ['--conf', '-c', GetoptLong::REQUIRED_ARGUMENT])
	begin
		parser.each do |opt, arg|
			case opt
			when '--path'
				tdiary_path = arg
			when '--conf'
				tdiary_conf = arg
			end
		end
	rescue
		usage
		exit( 1 )
	end

	tdiary_conf = tdiary_path unless tdiary_conf
	Dir::chdir( tdiary_conf )

	begin
		$:.unshift tdiary_path
		require "#{tdiary_path}/tdiary"
	rescue LoadError
		$stderr.puts "rast-register.rb: cannot load tdiary.rb. <#{tdiary_path}/tdiary>\n"
		$stderr.puts " usage: ruby rast-regiser.rb [-p <tDiary directory>] [-c <tdiary.conf directory>]"
		exit( 1 )
	end
end

require 'rast'

module ::TDiary
	#
	# Database
	#
	class RastDB
		DB_OPTIONS = {
			"preserve_text" => true,
			"properties" => [
				{
					"name" => "title",
					"type" => Rast::PROPERTY_TYPE_STRING,
					"search" => false,
					"text_search" => true,
					"full_text_search" => true,
					"unique" => false,
				},
				{
					"name" => "user",
					"type" => Rast::PROPERTY_TYPE_STRING,
					"search" => true,
					"text_search" => false,
					"full_text_search" => false,
					"unique" => false,
				},
				{
					"name" => "date",
					"type" => Rast::PROPERTY_TYPE_STRING,
					"search" => true,
					"text_search" => true,
					"full_text_search" => false,
					"unique" => false,
				},
				{
					"name" => "last_modified",
					"type" => Rast::PROPERTY_TYPE_DATE,
					"search" => true,
					"text_search" => false,
					"full_text_search" => false,
					"unique" => false,
				}
			]
		}

		attr_accessor :db
		attr_reader :conf, :encoding

		def initialize(conf, encoding)
			@conf = conf
			@encoding = encoding
			@db_options = {'encoding' => @encoding}.update(DB_OPTIONS)
			@db_options['properties'].delete_if{|i| i['name'] == 'user'} unless @conf['rast.with_user_name']
		end

		def transaction
			if !File.exist?(db_path)
				Rast::DB.create(db_path, @db_options)
			end
			Rast::DB.open(db_path, Rast::DB::RDWR, "sync_threshold_chars" => 500000) { |@db|
				yield self
			}
		end

		def cache_path
			@conf.cache_path || "#{@conf.data_path}cache"
		end

		def db_path
			@conf['rast.db_path'] || "#{cache_path}/rast".untaint
		end
	end

	#
	# Register
	#
	class RastRegister < TDiaryBase
		def initialize(rast_db, diary)
			@db = rast_db.db
			super(CGI::new, 'day.rhtml', rast_db.conf)
			@diary = diary
			@encoding = rast_db.encoding
			@date = diary.date
			@diaries = {@date.strftime('%Y%m%d') => @diary} if @diaries.empty?
			@plugin = ::TDiary::Plugin::new(
				'conf' => @conf,
				'cgi' => @cgi,
				'cache_path' => @io.cache_path,
				'diaries' => @diaries
				)
			def @plugin.apply_plugin_alt( str, remove_tag = false )
				apply_plugin( str, remove_tag )
			end
		end

		def execute(force = false)
			date = @date.strftime('%Y%m%d')
			last_modified = @diary.last_modified.strftime("%FT%T")
			options = {"properties" => ['last_modified']}
			if @conf['rast.with_user_name']
				result = @db.search("date : #{date} & user = #{@conf.user_name}", options)
			else
				result = @db.search("date : #{date}", options)
			end
			for item in result.items
				if force || item.properties[0] < last_modified
					@db.delete(item.doc_id)
				else
					return
				end
			end
			return unless @diary.visible?

			# body
			index = 0
			anchor = ''
			@diary.each_section do |section|
				index += 1
				@conf['apply_plugin'] = true
				anchor = "#{date}p%02d" % index
				title = CGI.unescapeHTML( @plugin.apply_plugin_alt( section.subtitle_to_html, true ).strip )
				if title.empty?
					title = @plugin.apply_plugin_alt( section.body_to_html, true ).strip
					title = @conf.shorten( CGI.unescapeHTML( title ), 20 )
				end
				body = CGI.unescapeHTML( @plugin.apply_plugin_alt( section.body_to_html, true ).strip )
				properties = {
					"title" => title,
					"date" => anchor,
					"last_modified" => last_modified,
				}
				properties["user"] = @conf.user_name if @conf['rast.with_user_name']
				@db.register(body, properties)
			end

			# comment
			@diary.each_visible_comment( 100 ) do |comment, index|
				if /^(TrackBack|Pingback)$/i =~ comment.name
					anchor = "#{date}t%02d" % index
					title = "TrackBack (#{comment.name})"
				else


					anchor = "#{date}c%02d" % index
					title = "#{@plugin.comment_description_short} (#{comment.name})"
				end
				body = comment.body
				properties = {
					"title" => title,
					"date" => anchor,
					"last_modified" => comment.date.strftime("%FT%T"),
				}
				properties["user"] = @conf.user_name if @conf['rast.with_user_name']
				@db.register(body, properties)
			end
		end
		
		protected

		def mode; 'day'; end
		def cookie_name; ''; end
		def cookie_mail; ''; end

		def convert(str)
			str
		end
	end

	#
	# Main
	#
	class RastRegisterMain < TDiaryBase
		def initialize(conf)
			super(CGI::new, 'day.rhtml', conf)
		end

		def execute(encoding, out = $stdout)
			require 'fileutils'
			calendar
			db = RastDB.new(conf, encoding)
			FileUtils.rm_rf(db.db_path)
			db.transaction do |rast_db|
				@years.keys.sort.each do |year|
					out << "(#{year.to_s}/) "
					@years[year.to_s].sort.each do |month|
						@io.transaction(Time::local(year.to_i, month.to_i)) do |diaries|
							diaries.sort.each do |day, diary|
								RastRegister.new(rast_db, diary).execute
								out << diary.date.strftime('%m%d ')
							end
							false
						end
					end
				end
			end
		end
	end
end

if mode == "CMD"
	begin
		require 'cgi'
		if TDiary::Config.instance_method(:initialize).arity != 0
			# for tDiary 2.1 or later
			cgi = CGI.new
			conf = TDiary::Config::new(cgi)
		else
			# for tDiary 2.0 or earlier
			conf = TDiary::Config::new
		end
		conf.header = ''
		conf.footer = ''
		conf.show_comment = true
		conf.hide_comment_form = true
		conf.show_nyear = false
		def conf.bot?; true; end
		encoding = 'utf8'
		TDiary::RastRegisterMain.new(conf).execute(encoding)
	rescue
		print $!, "\n"
		$@.each do |v|
			print v, "\n"
		end
		exit( 1 )
	end

	puts
else
	add_update_proc do
		conf = @conf.clone
		conf.header = ''
		conf.footer = ''
		conf.show_comment = true
		conf.hide_comment_form = true
		conf.show_nyear = false
		def conf.bot?; true; end

		diary = @diaries[@date.strftime('%Y%m%d')]
		encoding = 'utf8'
		TDiary::RastDB.new(conf, encoding).transaction do |rast_db|
			TDiary::RastRegister.new(rast_db, diary).execute(true)
		end
	end

	if !@conf['rast_register.hideconf'] && (@mode == 'conf' || @mode == 'saveconf')
		args = ['rast_register', @rast_register_conf_label]
		args << 'update' if TDIARY_VERSION > '2.1.3'
		add_conf_proc(*args) do
			str = <<-HTML
<h3 class="subtitle">#{@rast_register_conf_header}</h3>
<p>
<label for="rast_register_rebuild"><input id="rast_register_rebuild" type="checkbox" name="rast_register_rebuild" value="1">
#{@rast_register_conf_description}</label>
</p>
HTML
			if @mode == 'saveconf'
				if @cgi.valid?( 'rast_register_rebuild' )
					encoding = 'utf8'
					str << '<p>The following diaries were registered.</p>'
					out = ''
					TDiary::RastRegisterMain.new(@conf).execute(encoding, out)
					str << "<p>#{out}</p>"
				end
			end
			str
		end
	end
end
