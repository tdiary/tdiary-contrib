# -*- coding: utf-8 -*-
#
# appstore.rb - embeded AppStore data for tDiary,
# use App Store Affliate Resources Search API.
# http://www.apple.com/itunes/affiliates/resources/documentation/itunes-store-web-service-search-api.html
#
# Copyright (C) 2011, tamoot <tamoot+tdiary@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#

require 'uri'

if /\A(?:latest|day|month|nyear|preview)\z/ =~ @mode
   enable_js('appstore.js')
end

def appstore_detail(url)
   appstore_dom = ''
   
   begin
      appstore_dom = appstore_common(url, {:detail => true})
      
   rescue
      appstore_dom = "<b>Error. message=#{$!.message}.</b>"
      
   end
   
end

def appstore_common(url, params)
   return %Q|<a href="url">#{url}</a>| if feed?
   
   appstore_uri = URI::parse(url)
   id = appstore_uri.path.split('/').last.gsub('id', '')
   raise StandardError.new("AppStore ID: not found from #{url}..") if id.nil? || id == ''
   
   return %Q|<a class="appstore" data-appstoreid="#{id}" href="#{url}"></a>|
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3

