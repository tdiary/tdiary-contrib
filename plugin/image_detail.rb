# image_gps.rb $Revision: 1.0 $
# 
# 概要:
# 
#
# 使い方:
# 絵日記Plugin(image.rb)とおなじ
#
# Copyright (c) 2009 kp <kp@mmho.no-ip.org>
# Distributed under the GPL
#

=begin ChangeLog
2009-06-03 kp
  * first version
  * fork from image_gps2.rb
=end

require 'exifparser'

def tky2wgs lat,lon
  lat_w = lat - lat*0.00010695 + lon*0.000017464 + 0.0046017
  lon_w = lon - lat*0.000046038 - lon*0.000083043 + 0.010040
  lat = lat_w
  lon = lon_w
  return lat,lon
end

def image( id, alt = 'image', thumbnail = nil, size = nil, place = 'photo' )
  if @conf.secure then
    image = "#{@image_date}_#{id}.jpg"
    image_t = "#{@image_date}_#{thumbnail}.jpg" if thumbnail
  else
    image = image_list( @image_date )[id.to_i]
    image_t = image_list( @image_date )[thumbnail.to_i] if thumbnail
  end
  if size then
    if size.kind_of?(Array)
      size = " width=\"#{size[0]}\" height=\"#{size[1]}\""
      
    else
      size = " width=\"#{size.to_i}\""
    end
  else
    size = ""
  end
  
  exif = ExifParser.new("#{@image_dir}/#{image}".untaint) rescue nil
  
  google = "http://maps.google.co.jp"

  if exif
    #GPS Info
    begin
      lat = exif['GPSLatitude'].value
      lat = lat[0].to_f + lat[1].to_f/60 + lat[2].to_f/3600
      lat = -lat if exif['GPSLatitudeRef'].value == 'S'
      lon = exif['GPSLongitude'].value
      lon = lon[0].to_f + lon[1].to_f/60 + lon[2].to_f/3600
      lon = -lon if exif['GPSLongitudeRef'].value == 'W'
      datum = exif['GPSMapDatum'].value if exif.tag?('GPSMapDatum')
      lat,lon = tky2wgs(lat,lon) if datum == 'TOKYO'
    rescue
      lat = nil
    end
    detail = "<ul>"
    detail += "<li>#{exif['Model'].to_s}" if exif.tag?('Model')
    detail += "<li>焦点距離:#{exif['FocalLength'].to_s}" if exif.tag?('FocalLength')
    detail += "<li>F値:#{exif['FNumber'].to_s}" if exif.tag?('FNumber')
    detail += "<li>露出時間:#{exif['ExposureTime'].to_s}" if exif.tag?('ExposureTime')
    detail += "<li>露出補正:#{exif['ExposureBiasValue'].to_s}" if exif.tag?('ExposureBiasValue')
    unless lat.nil?
      img_map = %Q["http://maps.google.com/staticmap?format=gif&amp;]
      img_map += %Q[center=#{lat},#{lon}&amp;zoom=14&amp;size=200x200&amp;markers=#{lat},#{lon}&amp;]
      img_map += %Q[key=#{@conf['image_gps.google_maps_api_key']}&amp;sensor=false"]
      detail += %Q[<li><a href="#{google}/maps?q=#{lat},#{lon}">]
      detail += "#{exif['GPSLatitude'].to_s},#{exif['GPSLatitudeRef'].value}"
      detail += " #{exif['GPSLongitude'].to_s},#{exif['GPSLongitudeRef'].value}"
      detail += %Q[<img class="map" src=#{img_map}></a>]
    end
    detail += "</ul>"
  end

  img = %Q[<img class="#{place}" src="#{@image_url}/#{image}" alt="#{alt}" title="#{alt}" #{size}>]
  img_t = %Q[<img class="#{place}" src="#{@image_url}/#{image_t}" alt="#{alt}" title="#{alt}" #{size}>]
  
  #static map
  url  = ''
  if @conf.mobile_agent?
    url += %Q[<a href=#{img_map}>] unless lat.nil?
    url += thumbnail ? img_t : img
    url += %Q[</a>] unless lat.nil?
  else
    url += %Q[<div class="photo_detail">#{alt}] if detail
    url += %Q[<a href="#{@image_url}/#{image}">]
    url += thumbnail ? img_t : img
    url +=%Q[</a>]
    url += %Q[#{detail}</div>] if detail
  end
  url
end
add_header_proc do
  if @mode !~ /conf$/ and not bot? then
    <<-HTML
      <style type="text/css"><!--
        img.map{
          display:none;
          position:absolute;
          border:none;
        }
        a:hover img.map{
          display:inline;
        }
      --></style>
    HTML
  else
    ''
  end
end

add_conf_proc('image_gps','image_gpsの設定','etc') do
  if @mode == 'saveconf' then
    @conf['image_gps.add_info'] = @cgi.params['image_gps.add_info'][0]
    @conf['image_gps.google_maps_api_key'] = @cgi.params['image_gps.google_maps_api_key'][0]
  end
  
  <<-HTML
    <p>
    <h3>撮影条件の表示</h3>
    <input type="checkbox" name="image_gps.add_info" value="true" #{if @conf['image_gps.add_info'] then " checked" end}>タイトルに撮影条件を追加する
    <h3>Google Maps API Key</h3>
    <input type="text" name="image_gps.google_maps_api_key" value="#{@conf['image_gps.google_maps_api_key']}">
    </p>
  HTML

end
