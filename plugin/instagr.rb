# -*- coding: utf-8 -*-
#
# instagr.rb - plugin to insert images on instagr.am
#
# Copyright (C) 2011, tamoot <tamoot+tdiary@gmail.com>
# You can redistribute it and/or modify it under GPL2.
# 
# usage: 
# <%= instagr 'short URL instag.ram' =>
# <%= instagr 'short URL instag.ram', size}  =>
# 
# available size option:
#  :small  => 150x150 pixel
#  :medium => 306x306 pixel (default)
#  :large  => 612x612 pixel

require 'cgi'
require 'json'
require 'net/http'

def instagr( short_url, size = :medium)
	return %Q|<p>Argument is empty.. #{short_url}</p>| if !short_url or short_url.empty?
	option = option.nil? ? {} : option
	
	# img size
	maxwidth_data = {:small => 150, :medium => 306, :large => 612}
	maxwidth = maxwidth_data[ size ] ? maxwidth_data[ size ] : maxwidth_data[:medium]
	
	# proxy
	px_host, px_port = (@conf['proxy'] || '').split( /:/ )
	px_port = 80 if px_host and !px_port
	
	# query
	query = "?url=#{CGI::escape(short_url)}&maxwidth=#{maxwidth}"
	
	begin
		Net::HTTP.version_1_2
		res = Net::HTTP::Proxy(px_host, px_port).get('instagr.am', "/api/v1/oembed/#{query}")
		json_data = JSON::parse( res, &:read )
		width  = option[:width]  ? option[:width]  : json_data["width"]
		height = option[:height] ? option[:height] : json_data["height"]
		
		return <<-INSTAGR_DOM
			<div class="instagr">
				<a class="instagr" href="#{h short_url}" title="#{h @conf.to_native(json_data["title"])}">
					<img src="#{h json_data["url"]}" width="#{h width}" height="#{h height}" alt="#{h @conf.to_native(json_data["title"])}">
				</a>
				<p>#{h json_data["author_name"]}'s photo.</p>
			</div>
		INSTAGR_DOM
	rescue
		return %Q|<p>Failed Open URL.. #{short_url}<br>#{h $!}</p>|
	end
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
