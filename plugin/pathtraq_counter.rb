# pathtraq.rb $Revision 1.0 $
#
# Copyright (c) 2008 SHIBATA Hiroshi <shibata.hiroshi@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#

require 'timeout'
require 'open-uri'
require 'rubygems'
require 'json/ext'

def call_pathtraq_json( url, mode )
	json = nil
	begin
		timeout(10) do
			open( "http://api.pathtraq.com/page_counter?url=#{url}&m=#{mode}" ) do |f|
				json = JSON.parse( f.read )
			end
		end
	rescue => e
		@conf.debug( e )
	end
	return json
end

def pathtraq_count
	url = @conf.base_url
	mode = ['popular', 'hot', 'upcoming'] 

	r = %Q|<ul>\n|
	begin
		mode.each do |m|
			json = call_pathtraq_json( url, m )
			r << %Q|<li>#{m}: #{json["count"]}</li>\n| unless json.nil?
		end
	rescue => e
		@conf.debug( e )
	end
	r << %Q|</ul>\n|
	r << %Q|<div class="iddy"><span class="iddy-powered">Powered by <a href="http://pathtraq.com/">pathtraq</a></span></div>\n|

	return r
end
