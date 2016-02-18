# -*- coding: utf-8 -*-
#
# instagram.rb - embed your photo/videos in instagram to a diary
#
# Author: Tatsuya Sato
# License: GPL
require 'cgi'
require 'json'
require 'uri'
require 'net/http'
require 'open-uri'


def instagram(*args)
   uri = URI::parse(args[0])
   return instagram_iframe(*args) if uri.scheme.nil?
   return instagram_serverside(*args)
end

def instagram_iframe(code, width=612, height=700)
  return <<-BODY
<iframe src="//instagram.com/p/#{code}/embed/" width="#{width}" height="#{height}" frameborder="0" scrolling="no" allowtransparency="true"></iframe>
  BODY
end

def instagram_serverside( short_url, size = :medium)
   return %Q|<p>Argument is empty.. #{short_url}</p>| if !short_url or short_url.empty?
   option = option.nil? ? {} : option

   # img size
   size = size.to_sym if size != :medium
   maxwidth_data = {:medium => 320, :large => 612}
   maxwidth = maxwidth_data[ size ] ? maxwidth_data[ size ] : maxwidth_data[:medium]

   # proxy
   px_host, px_port = (@conf['proxy'] || '').split( /:/ )
   px_port = 80 if px_host and !px_port

   # query
   query = "?url=#{CGI::escape(short_url)}&maxwidth=#{maxwidth}"

   begin
      Net::HTTP.version_1_2
      res = Net::HTTP::Proxy(px_host, px_port).get('api.instagram.com', "/oembed/#{query}")
      json_data = JSON::parse( res, &:read )
      width  = option[:width]  ? option[:width]  : json_data["width"]
      height = option[:height] ? option[:height] : json_data["height"]
      return <<-INSTAGR_DOM
         <div class="instagr">
            <a class="instagr" href="#{h short_url}" title="#{h @conf.to_native(json_data["title"])}">
               <img src="#{h json_data["thumbnail_url"]}" width="#{h width}" height="#{h height}" alt="#{h @conf.to_native(json_data["title"])}">
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
