#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# git-register.rb
#
# Copyright (C) 2011 hajime miyauchi <hajime.miyauchi@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#
# tDiaryのデータを日別でGitに登録するプラグインです
# 
# 1. プラグインディレクトリ(例: plugin)にgit-register.rbを設置。
# 2. プラグインディレクトリにja/git-register.rb、en/git-register.rbを設置。
# 3. tdiary.confにリポジトリを指定(リポジトリの場所を/var/git-respoと仮定)
#    @options["git.repository_dir"] = "/var/git-repos"
# 4. リポジトリを作成(Apacheの起動ユーザをapacheと仮定)
#    $ mkdir /var/git-repos
#    $ cd /var/git-repos
#    $ git init
#    $ git config user.name "自分の名前"
#    $ git config user.email "メールアドレス"
#    $ chown apache.apache -R /var/git-repos
# 5. リポジトリに一括commit(tDiaryのインストールディレクトリを/var/www/tdiaryと仮定)
#    $ cd /var/www/tdiary
#    $ ruby --encoding=UTF-8 git-register.rb
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

if mode == "PLUGIN"
	add_body_leave_proc do |date|
	end
end

unless $tdiary_git_register_loaded
$tdiary_git_register_loaded ||= true

if mode == "CMD"
	tdiary_path = "."
	tdiary_conf = "."
	$stdout.sync = true

	def usage
		puts "git-register.rb"
		puts " register to git index files from tDiary's database."
		puts " usage: ruby --encoding=UTF-8 git-register.rb [-p <tDiary directory>] [-c <tdiary.conf directory>]"
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
		$stderr.puts "git-register.rb: cannot load tdiary.rb. <#{tdiary_path}/tdiary>\n"
		$stderr.puts " usage: ruby --encoding=UTF-8 git-register.rb [-p <tDiary directory>] [-c <tdiary.conf directory>]"
		exit( 1 )
	end
end

module ::TDiary
	#
	# Register
	#
	class GitRegister < TDiaryBase
		def initialize(repository_dir, diary)
			@repository_dir = repository_dir
			@diary = diary
			@date = diary.date
		end

		def execute()
			dir = @date.strftime("#{@repository_dir}%Y%m/")
			Dir::mkdir( dir ) unless FileTest::directory?( dir )

			td2_file = @date.strftime("#{dir}%Y%m%d.td2")
			fh = File::open(td2_file, 'w')

			fh.puts( "Date: #{@date}" )
			fh.puts( "Title: #{@diary.title}" )
			fh.puts( "Last-Modified: #{@diary.last_modified.to_i}" )
			fh.puts( "Visible: #{@diary.visible? ? 'true' : 'false'}" )
			fh.puts( "Format: #{@diary.style}" )
			fh.puts
			fh.puts( @diary.to_src.gsub( /\r/, '' ).gsub( /\n\./, "\n.." ) )

			fh.close

			# commit
			require 'shellwords'
			
			msg = "#{ENV['REMOTE_ADDR']} - #{ENV['REMOTE_HOST']}" 
			
			Dir.chdir("#{@repository_dir}") do
				td2_file2 = @date.strftime("%Y%m/%Y%m%d.td2")
				system("git add -- #{Shellwords.shellescape(td2_file2)}".untaint)
				system("git commit -q -m \"#{msg}\" -- #{Shellwords.shellescape(td2_file2)}".untaint)
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
	class GitRegisterMain < TDiaryBase
		def initialize(conf)
			super(CGI::new, 'day.rhtml', conf)
		end

		def execute(out = $stdout)
			require 'fileutils'
			repository_dir = @conf['git.repository_dir']
			calendar
			@years.keys.sort.reverse_each do |year|
				out << "(#{year.to_s}/) "
				@years[year.to_s].sort.reverse_each do |month|
					@io.transaction(Time::local(year.to_i, month.to_i)) do |diaries|
						diaries.sort.reverse_each do |day, diary|
							out << diary.date.strftime('%m%d ')
							GitRegister.new(repository_dir, diary).execute
						end
						false
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
		TDiary::GitRegisterMain.new(conf).execute
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

		repository_dir = @conf['git.repository_dir'] 
		diary = @diaries[@date.strftime('%Y%m%d')]
		
		TDiary::GitRegister.new(repository_dir, diary).execute
	end

	if !@conf['git.hideconf'] && (@mode == 'conf' || @mode == 'saveconf')
		args = ['git_register', @git_register_conf_label]
		args << 'update' if TDIARY_VERSION > '2.1.3'
		add_conf_proc(*args) do
			str = <<-HTML
<h3 class="subtitle">#{@git_register_conf_header}</h3>
<p>
<label for="git_register_rebuild"><input id="git_register_rebuild" type="checkbox" name="git_register_rebuild" value="1">
#{@git_register_conf_description}</label>
</p>
HTML
			if @mode == 'saveconf'
				if @cgi.valid?( 'git_register_rebuild' )
					str << '<p>The following diaries were registered.</p>'
					out = ''
					TDiary::GitRegisterMain.new(@conf).execute(out)
					str << "<p>#{out}</p>"
				end
			end
			str
		end
	end
end

end # $tdiary_git_register_loaded

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:

