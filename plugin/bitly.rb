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
require 'open-uri'

def bitly( long_url )
	return nil if !long_url or long_url.empty?

	@bitly_cache ||= {} # cached only on memory
	return @bitly_cache[long_url] if @bitly_cache[long_url]

	login = @conf['bitly.login']
	key = @conf['bitly.key']

	query = "/v3/shorten?longUrl=#{CGI::escape long_url}&login=#{login}&apiKey=#{key}&format=json"
   begin
      @bitly_cache[long_url] = JSON::parse( open( "http://api.bit.ly#{query}", &:read ) )['data']['url']
   rescue TypeError # biy.ly returns an error.
      nil
   end
end
