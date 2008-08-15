#
# Copyright (C) 2007 peo <peo@mb.neweb.ne.jp>
# You can redistribute it and/or modify it under GPL2.
#
# modified hsbt. 

require 'net/http'
require 'rubygems'
require 'json/ext'

module Wassr
	URL = 'api.wassr.jp'
	PATH = '/statuses/update.json'
	SOURCE = 'notify_wassr.rb'

	class Updater
		def initialize( user, pass )
			@user = user
			@pass = pass
		end

		# this code is based on http://la.ma.la/blog/diary_200704111918.htm
		def update( status )
			Net::HTTP.version_1_2
			req = Net::HTTP::Post.new(PATH)
			req.basic_auth(@user, @pass)
			req.body = 'status=' + URI.encode(status, /[^-.!~*'()\w]/n) + '&source=' + SOURCE

			Net::HTTP.start( URL, 80 ) do |http|
				response = http.request(req)
				json = JSON.parse(response.body)
				if json.has_key? 'error' 
					raise 'update failed.'
				end
			end
		end
	end
end

def notify_wassr
	notify_wassr_init

	date = @date.strftime('%Y%m%d')
	diary = @diaries[date]
	titles = []
	diary.each_section do |sec|
		titles << sec.subtitle
	end

	blogtitle = @conf.html_title
	sectitles = titles.join(', ')
	url = @conf.base_url + anchor(date)
	format = @conf['wassr.notify.format']
	prefix = @conf['wassr.notify.prefix']

	status = format % [prefix, blogtitle, sectitles, url]

	begin
		wsupdater = Wassr::Updater.new(@conf['wassr.user'], @conf['wassr.pass'] )
		wsupdater.update( status )
	rescue => e
		@conf.debug(e)
	end
end

def notify_wassr_init
	@conf['wassr.notify.prefix'] ||= '[blog update] '
	@conf['wassr.notify.format'] ||= '%s%s : %s %s'
end

add_update_proc do
	notify_wassr if @cgi.params['wassr.notify'][0] == 'true'
end

add_edit_proc do
	checked = ' checked'
	if @mode == 'preview' then
		checked = @cgi.params['wassr.notify'][0] == 'true' ? ' checked' : ''
	end
	<<-HTML
	<div class="wassr.notify"><label for="wassr.notify">
	<input type="checkbox" id="wassr.notify" name="wassr.notify" value="true"#{checked} tabindex="400">
	Post the update to Wassr
	</label>
	</div>
	HTML
end

add_conf_proc( 'notify_wassr', 'Wassr' ) do
	notify_wassr_init

	if @mode == 'saveconf' then
	   @conf['wassr.user'] = @cgi.params['wassr.user'][0]
	   @conf['wassr.pass'] = @cgi.params['wassr.pass'][0]
	   @conf['wassr.notify.prefix'] = @cgi.params['wassr.notify.prefix'][0]
	   @conf['wassr.notify.format'] = @cgi.params['wassr.notify.format'][0]
	end

	<<-HTML
   <h3 class="subtitle">Account Name</h3>
   <p><input name="wassr.user" value="#{h @conf['wassr.user']}" /></p>
   <h3 class="subtitle">Account Password</h3>
   <p><input name="wassr.pass" value="#{h @conf['wassr.pass']}" /></p>
   <h3 class="subtitle">Notify prefix</h3>
   <p><input name="wassr.notify.prefix" value="#{h @conf['wassr.notify.prefix']}" /></p>
   <h3 class="subtitle">Notify status format</h3>
   <p><input name="wassr.notify.format" value="#{h @conf['wassr.notify.format']}" /></p>
   HTML
end

# vim:ts=3
