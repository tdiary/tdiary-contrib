#
# goo_gl.rb - shorten URL by goo.gl
#
# usage: shorten_url_you_got = goo_gl( 'long_url' ) || long_url
#
# Copyright (C) 2011, tamoot <tamoot+tdiary@gmail.com>
# You can redistribute it and/or modify it under GPL.
#

require 'json'
require 'net/https'

def goo_gl( long_url )
   return nil if !long_url or long_url.empty?

   # on memory
   @goo_gl_cache ||= {} # cached only on memory
   return @goo_gl_cache[long_url] if @goo_gl_cache[long_url]

   # proxy
   px_host, px_port = (@conf['proxy'] || '').split( /:/ )
   px_port = 80 if px_host and !px_port

   # params
   params = {'longUrl' => long_url}.to_json

   https = nil
   begin
      https = Net::HTTP::Proxy(px_host, px_port).new('www.googleapis.com', 443)
      https.use_ssl = true
      res, body = https.post("/urlshortener/v1/url", params, {'Content-Type' => 'application/json'})
      @goo_gl_cache[long_url] = JSON::parse(body)["id"] if res.code == '200'
   rescue Exception => e
      # do nothing..

   ensure
      https.finish if https && https.started?

   end

   return @goo_gl_cache[long_url]
end
