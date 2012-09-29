#
# Copyright (C) 2007 peo <peo@mb.neweb.ne.jp>
# You can redistribute it and/or modify it under GPL2.
#
# modified hsbt.

require 'net/http'

@miniblog_config = (Struct.const_defined?("MiniBlogConfig") ? Struct::MiniBlogConfig :
	Struct.new("MiniBlogConfig", :host, :path))

@miniblog_list = {
	'HatenaHaiku' => @miniblog_config.new('h.hatena.ne.jp', '/api/statuses/update.json'),
}

module Miniblog
	class Updater
		def initialize( user, pass, config )
			@user = user
			@pass = pass
			@config = config
		end

		# this code is based on http://la.ma.la/blog/diary_200704111918.htm
		def update( status )
			Net::HTTP.version_1_2
			req = Net::HTTP::Post.new(@config.path)
			req.basic_auth(@user, @pass)
			req.body = status

			Net::HTTP.start( @config.host, 80 ) do |http|
				response = http.request(req)
				if response.body =~ /error/
					raise 'update failed.'
				end
			end
		end
	end
end

def notify_miniblog
	notify_miniblog_init

	date = @date.strftime('%Y%m%d')
	diary = @diaries[date]
	sectitle = ''
	index = 0

	diary.each_section do |sec|
		index += 1
		sectitle = sec.subtitle
	end

	# strip category
	sectitle.gsub!(/\[[^\]]+\] */, '')
	url = URI.encode(@conf.base_url + anchor("#{date}p%02d" % index), /[^-.!~*'()\w]/n)
	prefix = @conf['miniblog.notify.prefix']
	format = @conf['miniblog.notify.format']
	source = 'tdiary/notify_miniblog.rb'

	status = 'status=' + format % [prefix, sectitle, url] + '&source=' + source
	if @conf['miniblog.service'] == "HatenaHaiku" then
		status += '&keyword=id:' + @conf['miniblog.user']
	end

	config = @miniblog_list[@conf['miniblog.service']]

	begin
		miniblog_updater = Miniblog::Updater.new(@conf['miniblog.user'], @conf['miniblog.pass'], config)
		miniblog_updater.update( status )
	rescue => e
		@logger.debug( e )
	end
end

def notify_miniblog_init
	@conf['miniblog.notify.prefix'] ||= '[blog update]'
	@conf['miniblog.notify.format'] ||= '%s %s %s'
	@conf['miniblog.service'] ||= 'Twitter'
end

add_update_proc do
	if @mode == 'append' then
		notify_miniblog if @cgi.params['miniblog.notify'][0] == 'true'
	end
end

add_edit_proc do
	checked = ''
	if @mode == 'preview' then
		checked = @cgi.params['miniblog.notify'][0] == 'true' ? ' checked' : ''
	end
	<<-HTML
	<div class="miniblog.notify"><label for="miniblog.notify">
	<input type="checkbox" id="miniblog.notify" name="miniblog.notify" value="true"#{checked} tabindex="400">
	Post the update to #{@conf['miniblog.service']}
	</label>
	</div>
	HTML
end

add_conf_proc( 'notify_miniblog', 'MiniBlog' ) do
	notify_miniblog_init

	if @mode == 'saveconf' then
		@conf['miniblog.service'] = @cgi.params['miniblog.service'][0]
		@conf['miniblog.user'] = @cgi.params['miniblog.user'][0]
		@conf['miniblog.pass'] = @cgi.params['miniblog.pass'][0]
		@conf['miniblog.notify.prefix'] = @cgi.params['miniblog.notify.prefix'][0]
		@conf['miniblog.notify.format'] = @cgi.params['miniblog.notify.format'][0]
	end

	options = ''
	@miniblog_list.each_key do |key|
		options << %Q|<option value="#{h key}"#{" selected" if @conf['miniblog.service'] == key}>#{h key}</option>\n|
	end

	<<-HTML
	<h3 class="subtitle">MiniBlog Service</h3>
	<p><select name="miniblog.service">
		#{options}
	</select></p>
	<h3 class="subtitle">Account Name</h3>
	<p><input name="miniblog.user" value="#{h @conf['miniblog.user']}"></p>
	<h3 class="subtitle">Account Password</h3>
	<p><input name="miniblog.pass" value="#{h @conf['miniblog.pass']}"></p>
	<h3 class="subtitle">Notify prefix</h3>
	<p><input name="miniblog.notify.prefix" value="#{h @conf['miniblog.notify.prefix']}"></p>
	<h3 class="subtitle">Notify status format</h3>
	<p><input name="miniblog.notify.format" value="#{h @conf['miniblog.notify.format']}"></p>
	HTML
end

# vim:ts=3
