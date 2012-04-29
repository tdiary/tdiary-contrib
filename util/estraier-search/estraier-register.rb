#!/usr/bin/env ruby
# estraier-register.rb
#
# Copyright (C) 2007 Kazuhiko <kazuhiko@fdiary.net>
# You can redistribute it and/or modify it under GPL2.
#
require "estraierpure"

unless $tdiary_estraier_register_loaded
$tdiary_estraier_register_loaded ||= true

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
		puts "hyper-estraier-register.rb $Revision: 1.1.2.13 $"
		puts " register to hyper-estraier index files from tDiary's database."
		puts " usage: ruby hyper-estraier-regiser.rb [-p <tDiary directory>] [-c <tdiary.conf directory>]"
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
		$stderr.puts "hyper-estraier-register.rb: cannot load tdiary.rb. <#{tdiary_path}/tdiary>\n"
		$stderr.puts " usage: ruby hyper-estraier-regiser.rb [-p <tDiary directory>] [-c <tdiary.conf directory>]"
		exit( 1 )
	end
end

module ::TDiary
	#
	# Database
	#
	class EstraierDB
		attr_accessor :db
		attr_reader :conf

		def initialize(conf)
			@conf = conf
			@host = @conf["estraier.host"] || "localhost"
			@port = @conf["estraier.port"] || 1978
			@path = @conf["estraier.path"] || "/node/"
			@node = @conf["estraier.node"] || "tdiary"
			@name = @conf["estraier.name"] || "admin"
			@password = @conf["estraier.password"] || "admin"
		end

		def transaction
			db = EstraierPure::Node.new
			db.set_url("http://#{@host}:#{@port}#{@path}#{@node}")
			db.set_auth(@name, @password)

			if db.doc_num < 0
				raise "Database not found : http://#{@host}:#{@port}#{@path}#{@node}"
			end
			@db = db
			yield self
		end

		def cache_path
			@conf.cache_path || "#{@conf.data_path}cache"
		end
	end

	#
	# Register
	#
	class EstraierRegister < TDiaryBase
		def initialize(estraier_db, diary)
			@db = estraier_db.db
			super(CGI::new, 'day.rhtml', estraier_db.conf)
			@diary = diary
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
			cond = EstraierPure::Condition.new
			if @conf["estraier.with_user_name"]
				cond.add_attr("@uri STRBW #{@conf.user_name}:#{date}")
			else
				cond.add_attr("@uri STRBW #{date}")
			end
			result = @db.search(cond, 0)
			if result
				for i in 0...result.doc_num
					doc_id = result.get_doc(i).attr("@id")
					@db.out_doc(doc_id)
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
				last_modified = @diary.last_modified.strftime("%FT%T")
				body = CGI.unescapeHTML( @plugin.apply_plugin_alt( section.body_to_html, true ).strip )
				doc = EstraierPure::Document.new
				doc.add_attr("@title", title)
				if @conf["estraier.with_user_name"]
					doc.add_attr("@uri", "#{@conf.user_name}:#{anchor}")
				else
					doc.add_attr("@uri", anchor)
				end
				doc.add_attr("@mdate", last_modified)
				doc.add_hidden_text(title)
				doc.add_text(body)
				@db.put_doc(doc)
			end

			# comment
			@diary.each_visible_comment do |comment, index|
				if /^(TrackBack|Pingback)$/i =~ comment.name
					anchor = "#{date}t%02d" % index
					title = "TrackBack (#{comment.name})"
				else


					anchor = "#{date}c%02d" % index
					title = "#{@plugin.comment_description_short} (#{comment.name})"
				end
				body = comment.body
				doc = EstraierPure::Document.new
				doc.add_attr("@title", title)
				if @conf["estraier.with_user_name"]
					doc.add_attr("@uri", "#{@conf.user_name}:#{anchor}")
				else
					doc.add_attr("@uri", anchor)
				end
				doc.add_attr("@mdate", comment.date.strftime("%FT%T"))
				doc.add_hidden_text(title)
				doc.add_text(body)
				@db.put_doc(doc)
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
	class EstraierRegisterMain < TDiaryBase
		def initialize(conf)
			super(CGI::new, 'day.rhtml', conf)
		end

		def execute(out = $stdout)
			require 'fileutils'
			calendar
			db = EstraierDB.new(conf)
			db.transaction do |estraier_db|
				@years.keys.sort.reverse_each do |year|
					out << "(#{year.to_s}/) "
					@years[year.to_s].sort.reverse_each do |month|
						@io.transaction(Time::local(year.to_i, month.to_i)) do |diaries|
							diaries.sort.reverse_each do |day, diary|
								EstraierRegister.new(estraier_db, diary).execute
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
		TDiary::EstraierRegisterMain.new(conf).execute
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
		TDiary::EstraierDB.new(conf).transaction do |estraier_db|
			TDiary::EstraierRegister.new(estraier_db, diary).execute(true)
		end
	end

	if !@conf['estraier.hideconf'] && (@mode == 'conf' || @mode == 'saveconf')
		args = ['estraier_register', @estraier_register_conf_label]
		args << 'update' if TDIARY_VERSION > '2.1.3'
		add_conf_proc(*args) do
			str = <<-HTML
<h3 class="subtitle">#{@estraier_register_conf_header}</h3>
<p>
<label for="estraier_register_rebuild"><input id="estraier_register_rebuild" type="checkbox" name="estraier_register_rebuild" value="1">
#{@estraier_register_conf_description}</label>
</p>
HTML
			if @mode == 'saveconf'
				if @cgi.valid?( 'estraier_register_rebuild' )
					str << '<p>The following diaries were registered.</p>'
					out = ''
					TDiary::EstraierRegisterMain.new(@conf).execute(out)
					str << "<p>#{out}</p>"
				end
			end
			str
		end
	end
end

end # $tdiary_estraier_register_loaded
