# -*- coding: utf-8 -*-
#
# instagr.rb - plugin to insert images on instagr.am
#
# Copyright (C) 2011, tamoot <tamoot+tdiary@gmail.com>
# You can redistribute it and/or modify it under GPL2.
# 
# usage: 
# <%= instagr 'short URL instag.ram' =>
#

require 'cgi'
require 'json'
require 'open-uri'

def instagr( short_url, option = {})
  return %Q|<p>Argument is empty.. #{short_url}</p>| if !short_url or short_url.empty?
  
  query = "?url=#{CGI::escape(short_url)}"
  begin
    json_data = JSON::parse( open( "http://instagr.am/api/v1/oembed#{query}", &:read ) )
    width  = option[:width]  ? option[:width]  : json_data["width"]
    height = option[:height] ? option[:height] : json_data["height"]
    
    return <<-INSTAGR_DOM
    <div class="instagr">
      <a class="instagr" href="#{h short_url}">
        <img src="#{h json_data["url"]}" width="#{h width}" height="#{h height}" alt="#{h @conf.to_native(json_data["title"])}">
      </a>
      <p>Taken by #{h json_data["author_name"]}</p>
    </div>
    INSTAGR_DOM
  rescue
    return %Q|<p>Failed Open URL.. #{short_url}<br>#{h $!}</p>|
  end
end
