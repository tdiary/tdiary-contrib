# -*- coding: utf-8 -*-
#
# yo_update.rb - Yo all when an entry or a comment is posted
#
# Copyright (C) 2014, zunda <zundan at gmail.com>
#
# Permission is granted for use, copying, modification,
# distribution, and distribution of modified versions of this
# work under the terms of GPL version 2 or later.
#

require 'uri'
require 'timeout'
require 'net/http'
require 'json'

YO_UPDATE_TIMEOUT = 10

class YoUpdateError < StandardError; end

def yo_update_url(date = nil, frag = nil)	# date: Time frag: e.g. 'p01'
	url = @conf.index.dup
	url[0, 0] = base_url unless %r|^https?://|i =~ url
	url.gsub!( %r|/\./|, '/' )
	if date
		ymd = date.strftime('%Y%m%d')
		anc = frag ? "#{ymd}##{frag}" : ymd
		url += anchor(anc)
	end
	url
end

def yo_update_api_key
	r = @conf['yo_update.api_key']
	if not r or r.empty?
		return nil
	end
	return r
end

def yo_update_access_api(req)
	if @conf['proxy']
		proxy_uri = URI("http://" + @conf['proxy'])
		proxy_addr = proxy_uri.host
		proxy_port = proxy_uri.port
	else
		proxy_addr = nil
		proxy_port = nil
	end
	begin
		Timeout.timeout(YO_UPDATE_TIMEOUT) do
			return Net::HTTP.start(req.uri.host, req.uri.port, proxy_addr, proxt_port){|http|
				http.request(req)
			}
		end
	rescue Timeout::Error
		raise YoUpdateError, "Timeout accessing Yo API"
	rescue SocketError => e
		raise YoUpdateError, e.message
	end
end

def yo_update_send_yo(username = nil, url = '')
	api_key = yo_update_api_key
	unless api_key
		raise YoUpdateError, "Yo API Key is not set"
	end
	data = {'api_token' => api_key}
	data['link'] = url unless url.empty?
	unless username
		req = Net::HTTP::Post.new(URI("http://api.justyo.co/yoall/"))
		req.set_form_data(data)
		expected = '{}'
	else
		req = Net::HTTP::Post.new(URI("http://api.justyo.co/yo/"))
		data['username'] = username
		req.set_form_data(data)
		expected = '{"result": "OK"}'
	end
	res = yo_update_access_api(req)
	data = res.body
	unless data == expected
		raise YoUpdateError, "error from Yo API: #{data}"
	end
	return data
end

def yo_update_send_yo_or_log(username = nil, url = '')
	return unless yo_update_api_key
	begin
		yo_update_send_yo(username, url)
	rescue YoUpdateError => e
		@logger.error "yo_update.rb: #{e.message}"
	end
end

def yo_update_subscribers_count
	api_key = yo_update_api_key
	unless api_key
		raise YoUpdateError, "Yo API Key is not set"
	end
	req = Net::HTTP::Get.new(
		URI("http://api.justyo.co/subscribers_count/?api_token=#{URI.escape(api_key)}")
	)
	res = yo_update_access_api(req)
	data = res.body
	begin
		r = JSON::parse(data)
		if r.has_key?('result')
			return r['result']
		else
			raise YoUpdateError, "Error from Yo API: #{data}"
		end
	rescue JSON::ParserError
		raise YoUpdateError, "Error from Yo API: #{data}"
	end
end

unless defined? yo_update_conf_label	# maybe defined in a language resource
	def yo_update_conf_label
		'Send Yo with updates'
	end
end

unless defined? yo_update_test_result_label	# maybe defined in a language resource
	def yo_update_test_result_label(username, result)
		"- Sent to <tt>#{h username}</tt> and got <tt>#{h result}</tt>"
	end
end

unless defined? yo_update_conf_html	# maybe defined in a language resource
	def yo_update_conf_html(conf, n_subscribers, test_result)
		action_label = {
			'send_on_update' => 'when an entry is added',
			'send_on_comment' => 'when a comment is posted',
		}
		<<-HTML
		<h3 class="subtitle">API key</h3>
		<p><input name="yo_update.api_key" value="#{h conf['yo_update.api_key']}" size="40"></p>
		<h3 class="subtitle">Username</h3>
		<p><input name="yo_update.username" value="#{h conf['yo_update.username']}" size="40"></p>
		<h3 class="subtitle">Send Yo</h3>
		<ul>
		#{%w(send_on_update send_on_comment).map{|action|
			checked = conf["yo_update.#{action}"] ? ' checked' : ''
			%Q|<li><label for="yo_update.#{action}"><input id="yo_update.#{action}" name="yo_update.#{action}" value="t" type="checkbox"#{checked}>#{action_label[action]}</label>|
		}.join("\n\t")}
		</ul>
		<p>Test sending Yo! to <input name="yo_update.test" value="" size="10"> with optional link <input name="yo_update.link" value="#{yo_update_url}" size="40">#{test_result}</p>
		<h3 class="subtitle">Current Subscribers</h3>
		<p>#{h n_subscribers}</p>
		<h3 class="subtitle">Yo button</h3>
		<p>Add the following to somewhere or your diary.</p>
		<pre>&lt;div id=&quot;yo-button&quot;&gt;&lt;/div&gt;</pre>
		<h3 class="subtitle">Howto</h3>
		<ol>
		<li>Sign in with your personal Yo account at <a href="http://dev.justyo.co/">http://dev.justyo.co/</a>
		<li>Follow the instructions to obtain new API account.
			Please leave the Callback URL blank.
		<li>Copy the API key and API username above.
		</ol>
		HTML
	end
end

add_conf_proc('yo_update', yo_update_conf_label) do
	test_result = ''
	if @mode == 'saveconf' then
		@conf['yo_update.api_key'] = @cgi.params['yo_update.api_key'][0]
		@conf['yo_update.username'] = @cgi.params['yo_update.username'][0]
		@conf['yo_update.send_on_update'] = (@cgi.params['yo_update.send_on_update'][0] == 't')
		@conf['yo_update.send_on_comment'] = (@cgi.params['yo_update.send_on_comment'][0] == 't')
		test_username = @cgi.params['yo_update.test'][0]
		test_link = @cgi.params['yo_update.link'][0]
		if test_username and not test_username.empty?
			begin
				result = yo_update_send_yo(test_username, test_link)
			rescue YoUpdateError => e
				result = e.message
			end
			test_result = yo_update_test_result_label(test_username, result)
		end
	end
	unless @conf.has_key?('yo_update.send_on_update')
		@conf['yo_update.send_on_update'] = true
	end
	begin
		n_subscribers = yo_update_subscribers_count
	rescue YoUpdateError => e
		n_subscribers = e.message
	end
	yo_update_conf_html(@conf, n_subscribers, test_result)
end

add_update_proc do
	if @mode == 'append' and @conf['yo_update.send_on_update']
		url = yo_update_url(@date)	# link to the date
		yo_update_send_yo_or_log(nil, url)
	elsif @mode == 'comment' and @comment and @comment.visible? and @conf['yo_update.send_on_comment']
		frag = "c%02d" % @diaries[@date.strftime("%Y%m%d")].count_comments(true)
		url = yo_update_url(@date, frag)
		yo_update_send_yo_or_log(nil, url)
	end
end

add_header_proc do
	if @conf['yo_update.api_key']
		triggers = []
		triggers << 'Entry' if @conf['yo_update.send_on_update']
		triggers << 'Tsukkomi' if @conf['yo_update.send_on_comment']
		trigger_str = "#{triggers.join(' or ')} is added"
		<<-HTML
	<script type="text/javascript"><!--
		var _yoData = {
			"username": "#{@conf['yo_update.username']}",
			"trigger": "#{trigger_str}"
		};
		var s = document.createElement("script");
		s.type = "text/javascript";
		s.src = "//yoapp.s3.amazonaws.com/js/yo-button.js";
		(document.head || document.getElementsByTagName("head")[0]).appendChild(s);
	--></script>
		HTML
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3 sw=3
