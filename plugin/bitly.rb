#
# bitly.rb - shorten URL by bit.ly.
#
# usage: shorten_url_you_got = bitly( 'long_url' ) || long_url
#        (because bitly returns nil sometime.)
#
# required some options below:
#    @options['biyly.login'] : your login ID of bit.ly.
#    @options['biyly.key']   : your API key of biy.ly.
#
# Copyright (C) 2010, TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL.
#

require 'json'
require 'net/http'

def bitly( long_url )
	return nil if !long_url or long_url.empty?

	@bitly_cache ||= {} # cached only on memory
	return @bitly_cache[long_url] if @bitly_cache[long_url]

	login = @conf['bitly.login']
	key = @conf['bitly.key']

	# proxy
	px_host, px_port = (@conf['proxy'] || '').split( /:/ )
	px_port = 80 if px_host and !px_port

	query = "/v3/shorten?longUrl=#{CGI::escape long_url}&login=#{login}&apiKey=#{key}&format=json"
	begin
		Net::HTTP.version_1_2
		res = Net::HTTP::Proxy(px_host, px_port).get('api.bit.ly', "#{query}")
		@bitly_cache[long_url] = JSON::parse(res, &:read)['data']['url']
	rescue TypeError => te# biy.ly returns an error.
		nil
	end
end
