# -*- coding: utf-8 -*-
#
# tweet_quote.rb - tDiary plugin to quote tweet on twitter.com,
# formaly known as blackbird-pie.rb
#
# Copyright (C) 2010, hb <smallstyle@gmail.com>
#
# usage:
#    <%= tweet_quote "id|url" %>
#     or
#    <%= twitter_quote "id|url" %>
#     or
#    <%= blackbird_pie "id|url" %>
#     or
#    <%= bbp "id|url" %>
#

require 'pstore'
require 'open-uri'
require 'timeout'
require 'time'
require 'uri'
require 'openssl'
require 'json'

def twitter_quote_option_keys
	%w( oauth_consumer_key oauth_consumer_secret oauth_token oauth_token_secret render_method ).map{|k| "twitter_quote.#{k}" }
end

def twitter_statuses_show_api( tweet_id )
	url = "https://api.twitter.com/1.1/statuses/show.json"
	unsafe = /[^a-zA-Z0-9\-\.\_\~]/
	parameters = {
		:id => tweet_id
	}
	oauth_parameters = {
		:oauth_consumer_key => @conf["twitter_quote.oauth_consumer_key"],
		:oauth_nonce => OpenSSL::Digest.hexdigest( "MD5", "#{Time.now.to_f}#{rand}" ),
		:oauth_signature_method => "HMAC-SHA1",
		:oauth_timestamp => Time.now.to_i.to_s,
		:oauth_token => @conf["twitter_quote.oauth_token"],
		:oauth_version => "1.0"
	}
	data = "GET&#{URI.escape( url, unsafe )}&"
	data << URI.escape( oauth_parameters.merge( parameters ).sort.map{|k, v| "#{k}=#{v}" }.join( "&" ), unsafe )
	oauth_parameters[:oauth_signature] = [OpenSSL::HMAC.digest(
		OpenSSL::Digest::SHA1.new,
		URI.escape( "#{@conf["twitter_quote.oauth_consumer_secret"]}&#{@conf["twitter_quote.oauth_token_secret"]}" ),
		data
	)].pack( "m" ).chomp

	proxy = @conf['proxy']
	proxy = 'http://' + proxy if proxy

	headers = {
		"Authorization" => %Q[OAuth #{oauth_parameters.map{|k ,v| "#{URI.escape( k.to_s, unsafe )}=\"#{URI.escape( v, unsafe )}\""}.join( "," )}],
		:proxy => proxy
	}
	Timeout.timeout( 20 ) do
		open( "#{url}?#{parameters.map{|k,v| "#{k}=#{v}"}.join( "&" )}", headers ) {|f| f.read }
	end
end

def render_widget(tweet_id, screen_name, name, background_url, profile_backgound_color, avatar, source, timestamp, content)
  <<-HTML
<blockquote class="twitter-tweet"><p>#{content}</p>
&mdash; #{@name} (#{@screen_name}) <a href="http://twitter.com/#{screen_name}/status/#{tweet_id}">#{timestamp}</a>
</blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
  HTML
end

def render_bbp(tweet_id, screen_name, name, background_url, profile_backgound_color, avatar, source, timestamp, content)
  <<-HTML
	<!-- http://twitter.com/#{screen_name}/status/#{tweet_id} -->
	<div class="bbpBox" style="background:url(#{background_url}) #{profile_background_color};padding:20px;">
		<p class="bbpTweet" style=
		"background:#fff;padding:10px 12px 10px 12px;margin:0;min-height:48px;color:#000;font-size:16px !important;line-height:22px;-moz-border-radius:5px;-webkit-border-radius:5px;">
		<span class="bbpMetadata" style=
		"display:block;width:100%;clear:both;margin-bottom:8px;padding-bottom:12px;height:40px;border-bottom:1px solid #fff;border-bottom:1px solid #e6e6e6;">
		<span class="bbpAuthor" style="line-height:19px;"><a href=
		"http://twitter.com/#{screen_name}"><img alt="#{name}" src=
		"#{avatar}" style=
		"float:left;margin:0 17px 0 0;width:38px;height:38px;"></a>
		<a href="http://twitter.com/#{screen_name}" style="text-decoration:none">
		<strong style="text-decoration:underline">#{name}</strong><br>
		@#{screen_name}</a></span></span>
		#{content} <span class="bbpTimestamp" style=
		"font-size:12px;display:block;"><a title="#{timestamp}" href=
		"http://twitter.com/#{screen_name}/status/#{tweet_id}">#{timestamp}</a>
		<span style="float:right"><a href=
		"https://twitter.com/intent/tweet?in_reply_to=#{tweet_id}">Reply</a> <a href=
		"https://twitter.com/intent/retweet?tweet_id=#{tweet_id}">Retweet</a> <a href=
		"https://twitter.com/intent/favorite?tweet_id=#{tweet_id}"}>Favorite</a>
		</span></span></p>
	</div>
	<!-- end of tweet -->
	HTML
end

def twitter_status_json_to_html( json )
	tweet_id = json['id_str']
	screen_name = json['user']['screen_name']
	name = json['user']['name']
	background_url = json['user']['profile_background_image_url']
	profile_background_color = "##{json['user']['profile_background_color']}"
	avatar = json['user']['profile_image_url']
	source = json['source']
	timestamp = Time.parse( json['created_at'] )
	content = json['text']
	content.gsub!( URI.regexp( %w|http https| ) ){ %Q|<a href="#{$&}">#{$&}</a>| }
	content = content.split( /(<[^>]*>)/ ).map {|s|
		next s if s[/\A</]
		s.gsub!( /@(?>([a-zA-Z0-9_]{1,15}))(?![a-zA-Z0-9_])/ ){ %Q|<a href="http://twitter.com/#{$1}">#{$&}</a>| }
		s.gsub( /#([a-zA-Z0-9]{1,16})/ ){ %Q|<a href="http://twitter.com/search?q=%23#{$1}">#{$&}</a>| }
	}.join

	if @conf['twitter_quote.render_method'] == 'widget'
		render_widget(tweet_id, screen_name, name, background_url, profile_backgound_color, avatar, source, timestamp, content)
	else
		render_bbp(tweet_id, screen_name, name, background_url, profile_backgound_color, avatar, source, timestamp, content)
	end
end

def tweet_quote( src )
	return unless twitter_quote_option_keys.all?{|v| @options.key? v }

	if %r|http(?:s)?://twitter.com/(?:#!/)?[^/]{1,15}/status(?:es)?/([0-9]+)| =~ src.to_s.downcase
		src = $1
	end

	return unless /\A[0-9]+\z/ =~ src.to_s

	cache = "#{@cache_path}/tweet_quote.pstore"
	json = nil

	db = PStore.new( cache )
	db.transaction do
		key = src
		db[key] ||= {}
		if db[key][:json] && /\A(?:latest|day|month|nyear)\z/ =~ @mode
			json = db[key][:json]
		else
			begin
				json = twitter_statuses_show_api( src )
			rescue OpenURI::HTTPError
				return %Q|<p class="tweet_quote_error">#$!</p>|
			end
			db[key][:json] = json
		end
	end
	twitter_status_json_to_html( JSON.parse( json ) )
end

add_conf_proc( 'twitter_quote', 'Embedded Tweets' ) do
	if @mode == 'saveconf'
		twitter_quote_option_keys.each do |k|
			@conf[k] = @cgi.params[k][0]
		end
	end
	<<-HTML
	<h2>Twitter OAuth settings</h2>
	<h3>Consumer key</h3>
	<p><input type="text" name="twitter_quote.oauth_consumer_key" value="#{h @conf["twitter_quote.oauth_consumer_key"]}" size="80"></p>
	<h3>Consumer secret</h3>
	<p><input type="text" name="twitter_quote.oauth_consumer_secret" value="#{h @conf["twitter_quote.oauth_consumer_secret"]}" size="80"></p>
	<h2>Your access token</h2>
	<h3>Access token</h3>
	<p><input type="text" name="twitter_quote.oauth_token" value="#{h @conf["twitter_quote.oauth_token"]}" size="80"></p>
	<h3>Access token secret</h3>
	<p><input type="text" name="twitter_quote.oauth_token_secret" value="#{h @conf["twitter_quote.oauth_token_secret"]}" size="80"></p>
        <h3>Render method</h3>
	<select name="twitter_quote.render_method">
	<option value="bbp"#{' selected' if @conf['twitter_quote.render_method'] == 'bbp'}>Bbp</option>
	<option value="widget"#{' selected' if @conf['twitter_quote.render_method'] == 'widget'}>Widget</option>
	</select>
        </p>
	HTML
end

alias :blackbird_pie :tweet_quote
alias :bbp :tweet_quote
alias :twitter_quote :tweet_quote
