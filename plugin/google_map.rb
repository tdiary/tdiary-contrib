# -*- coding: utf-8 -*-
#
# google_map.rb - embeded Google Map for tDiary, use Google Maps JavaScript API V3.
#                 http://code.google.com/intl/ja/apis/maps/documentation/v3/services.html
#
# Copyright (C) 2010, tamoot <tamoot+tdiary@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#


def google_map(lat, lon, params = {})
   params.merge!(:lat => lat, :lon => lon)
   google_map_common(params)
end

def google_geomap(address, params = {})
   params.merge!(:address => address)
   google_map_common(params)
end

def google_map_common(params)
   init_gmap_data
   if feed?
     require 'cgi'
     query = params[:lat] && params[:lon] ? "#{params[:lat]},#{params[:lon]}" : params[:address]
     url = %Q|http://maps.google.com/maps?q=#{CGI::escape(query)}|
     return %Q|<a href="#{url}">#{url}</a>|
   end
   return 'not support this environment.' if @conf.mobile_agent?
   
   params[:zoom]    ||=  10
   params[:html]    ||= nil
   params[:title]   ||= nil
   params[:width]   ||= 320
   params[:height]  ||= 240
   params[:address] ||= nil
   params[:type]    ||= :ROADMAP
   params[:overview]||= false
   
   dom_id = "#{@date.strftime("%Y%m")}_#{@gmap_count}"
   params.merge!(:id => dom_id)
   params.merge!(:width => 240, :height => 180) if @conf.iphone?
   @gmap_data << params
   @gmap_count += 1
   %Q|<div class="gmap" id="#{dom_id}" style="width : #{params[:width]}px; height : #{params[:height]}px;"></div>|
end


add_header_proc do
   if /\A(?:latest|day|month|nyear|preview)\z/ =~ @mode
      %Q|<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=#{!@conf.smartphone?.nil?}"></script>\n|
   end
end



add_body_leave_proc do |date|
   init_gmap_data
   gmap_scripts = ''
   if !feed? && @gmap_data.any?
      gmap_scripts = %Q|<script type="text/javascript">\n<!--\n|
      while @gmap_data.any?
         data = @gmap_data.shift
         if data[:address]
            gmap_scripts << google_geomap_script(data)
         else
            gmap_scripts << google_map_script(data)
         end
      end
      gmap_scripts << %Q|//-->\n</script>\n|
   end
   gmap_scripts
end

def init_gmap_data
   @gmap_data  ||= []
   @gmap_count ||= 0
end

def google_map_script(hash)
   str = ''
   str << %Q|google.maps.event.addDomListener(window, 'load', function() {\n|
   str << %Q|  var mapdiv = document.getElementById("#{hash[:id]}");\n|
   str << %Q|  var myOptions = {\n|
   str << %Q|        zoom: #{hash[:zoom]},\n|
   str << %Q|        overviewMapControl: #{hash[:overview]},\n|
   str << %Q|        overviewMapControlOptions: {\n|
   str << %Q|            opened: #{hash[:overview]}\n|
   str << %Q|        },\n|
   str << %Q|        center: new google.maps.LatLng(#{hash[:lat]}, #{hash[:lon]}),\n|
   str << %Q|        mapTypeId: google.maps.MapTypeId.#{hash[:type]},\n|
   str << %Q|        scaleControl: true\n|
   str << %Q|      };\n|
   str << %Q|  var gMap = new google.maps.Map(mapdiv, myOptions);\n|
   # set Marker
   if hash[:title]
   str << %Q|  var marker = new google.maps.Marker({\n|
   str << %Q|      position: new google.maps.LatLng(#{hash[:lat]}, #{hash[:lon]}),\n|
   str << %Q|      map: gMap,\n| 
   str << %Q|      title: '#{hash[:title]}'\n|
   str << %Q|  });\n|
   # set InfoWindow
   if hash[:html]
   str << %Q|  var infowindow = new google.maps.InfoWindow({\n|
   str << %Q|      content: '<span style="color: #000000;">#{hash[:html]}</span>',\n|
   str << %Q|      size: new google.maps.Size(350, 200)\n|
   str << %Q|  });\n|
   str << %Q|  infowindow.open(gMap, marker);\n|
   end # :html
   end # :title
   str << %Q|});\n|
    
   str
end

def google_geomap_script(hash)
   str = ''
   str << %Q|google.maps.event.addDomListener(window, 'load', function() {\n|
   str << %Q|  var geocoder = new google.maps.Geocoder();\n|
   str << %Q|  if(geocoder) {\n|
   str << %Q|    geocoder.geocode( { 'address': '#{hash[:address]}'}, function(results, status) {\n|
   str << %Q|      if (status == google.maps.GeocoderStatus.OK) {\n|
   str << %Q|        var geoLat = results[0].geometry.location;\n|
   str << %Q|        var mapdiv = document.getElementById("#{hash[:id]}");\n|
   str << %Q|        var myOptions = {\n|
   str << %Q|          zoom: #{hash[:zoom]},\n|
   str << %Q|          overviewMapControl: #{hash[:overview]},\n|
   str << %Q|          overviewMapControlOptions: {\n|
   str << %Q|            opened: #{hash[:overview]}\n|
   str << %Q|          },\n|
   str << %Q|          center: geoLat,\n|
   str << %Q|          mapTypeId: google.maps.MapTypeId.#{hash[:type]},\n|
   str << %Q|          scaleControl: true\n|
   str << %Q|        };\n|
   str << %Q|        var gMap = new google.maps.Map(mapdiv, myOptions);\n|
   # set Marker
   if hash[:title]
   str << %Q|        var marker = new google.maps.Marker({\n|
   str << %Q|            position: geoLat,\n|
   str << %Q|            map: gMap,\n| 
   str << %Q|            title: '#{hash[:title]}'\n|
   str << %Q|        });\n|
   # set InfoWindow
   if hash[:html]
   str << %Q|        var infowindow = new google.maps.InfoWindow({\n|
   str << %Q|            content: '<span style="color: #000000;">#{hash[:html]}</span>',\n|
   str << %Q|            size: new google.maps.Size(350, 200)\n|
   str << %Q|        });\n|
   str << %Q|        infowindow.open(gMap, marker);\n|
   end # :html
   end # :title
   str << %Q|      }else{\n|
   str << %Q|        alert("Geocode was not successful for the following reason: " + status)\n|
   str << %Q|      }\n|
   str << %Q|    });\n|
   str << %Q|  }\n|
   str << %Q|});\n|
    
   str
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
