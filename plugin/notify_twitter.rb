#
# Copyright (C) 2007 peo <peo@mb.neweb.ne.jp>
# You can redistribute it and/or modify it under GPL2.
#
require 'net/http'

module Twitter
	URL = 'twitter.com'
	PATH = '/statuses/update.json'

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
			req.body = 'status=' + URI.encode(status, /[^-.!~*'()\w]/n)

			Net::HTTP.start(URL, 80) {|http|
					res = http.request(req)
			}
		end
	end
end

def notify_twitter
	date = @date.strftime('%Y%m%d')

	diary = @diaries[date]
	titles = []
	diary.each_section do |sec|
		titles << sec.subtitle
	end
	sectitles = titles.join(', ')
	blogtitle = @conf.html_title
	url = @conf.base_url + anchor(date)

	notify_twitter_init

	format = @conf['twitter.notify.format']
	prefix = @conf['twitter.notify.prefix']
	status = format % [prefix, blogtitle, sectitles, url]

	user = @conf['twitter.user']
	pass = @conf['twitter.pass']
	twupdater = Twitter::Updater.new(user, pass)
	twupdater.update( status )
end

def notify_twitter_init
	@conf['twitter.notify.prefix'] ||= '[blog update] '
	@conf['twitter.notify.format'] ||= '%s%s : %s %s'
end

add_update_proc do
	notify_twitter if @cgi.params['twitter.notify'][0] == 'true'
end

add_edit_proc do
	checked = ' checked'
	if @mode == 'preview' then
		checked = @cgi.params['twitter.notify'][0] == 'true' ? ' checked' : ''
	end
	<<-HTML
	<div class="twitter.notify">
	<input type="checkbox" name="twitter.notify" value="true"#{checked} tabindex="400">
	Post the update to Twitter
	</div>
	HTML
end

add_conf_proc( 'notify_twitter', 'Twitter' ) do
	notify_twitter_init

	if @mode == 'saveconf' then
	   @conf['twitter.user'] = @cgi.params['twitter.user'][0]
	   @conf['twitter.pass'] = @cgi.params['twitter.pass'][0]
	   @conf['twitter.notify.prefix'] = @cgi.params['twitter.notify.prefix'][0]
	   @conf['twitter.notify.format'] = @cgi.params['twitter.notify.format'][0]
	end

	<<-HTML
   <h3 class="subtitle">Account Name</h3>
   <p><input name="twitter.user" value="#{h @conf['twitter.user']}" /></p>
   <h3 class="subtitle">Account Password</h3>
   <p><input name="twitter.pass" value="#{h @conf['twitter.pass']}" /></p>
   <h3 class="subtitle">Notify prefix</h3>
   <p><input name="twitter.notify.prefix" value="#{h @conf['twitter.notify.prefix']}" /></p>
   <h3 class="subtitle">Notify status format</h3>
   <p><input name="twitter.notify.format" value="#{h @conf['twitter.notify.format']}" /></p>
   HTML
end

# vim:ts=3
