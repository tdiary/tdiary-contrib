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

def bitly( long_uri )
	return nil if !long_uri or long_uri.empty?

	login = @conf['bitly.login']
	key = @conf['bitly.key']

	query = "/v3/shorten?longUrl=#{CGI::escape long_uri}&login=#{login}&apiKey=#{key}&format=json"
   begin
      JSON::parse( open( "http://api.bit.ly#{query}", &:read ) )['data']['url']
   rescue TypeError # biy.ly returns an error.
      nil
   end
end
