# -*- coding: utf-8 -*-
# image_gps.rb $Revision: 1.1 $
#
# 概要:
#
#
# 使い方:
# 絵日記Plugin(image.rb)とおなじ
#
# Copyright (c) 2009,2010 kp <kp@mmho.no-ip.org>
# Distributed under the GPL
#

=begin ChangeLog
2010-04-21 kp
  * スマートフォン対応
  * Google Maps API Keyが設定されていない場合はStaticMAPを生成しない
  * リンク先をGoogle Mapsに統一
2009-06-03 kp
  * first version
  * fork from image_gps2.rb
=end

begin
  require 'exifparser'
rescue
  retry if require 'rubygems'
end

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

  if size
    if size.kind_of?(Array)
      if size.length > 1
        size = %Q| width="#{h size[0]}" height="#{h size[1]}"|
      elsif size.length > 0
        size = %Q| width="#{h size[0]}"|
      end
    else
      size = %Q| width="#{size.to_i}"|
    end
  elsif @image_maxwidth and not @conf.secure then
    _, w, _ = image_info( "#{@image_dir}/#{image}".untaint )
    if w > @image_maxwidth then
      size = %Q[ width="#{h @image_maxwidth}"]
    else
      size = ""
    end
  end

  show_exif_info = @conf['image_gps.show_exif_info']
  show_exif_info = '' if show_exif_info.nil?
  google_maps_api_key = @conf['image_gps.google_maps_api_key']
  google_maps_api_key = '' if google_maps_api_key.nil?
  if (@conf['image_gps.map_link_url'].nil? || @conf['image_gps.map_link_url'].empty?)
    map_link_url = '"//maps.google.co.jp/maps?q=#{lat},#{lon}"'
  else
    map_link_url = '"'+@conf['image_gps.map_link_url']+'"'
  end

  exif = ExifParser.new("#{@image_dir}/#{image}".untaint) rescue nil

  if exif
    #GPS Info
    begin
      raise if exif['GPSLatitudeRef'].value.length==0
      raise if exif['GPSLongitudeRef'].value.length==0
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

    # show exif info
    sep=' '  # ToDo: separator to config param.

    detail =%Q[<p class="exif_info">]
    show_exif_info.split(' ').each{|e|
      detail += "#{exif[e].to_s}"+sep if exif.tag?(e)
    }
    unless lat.nil?
      unless google_maps_api_key == ''
        map_img = %Q["//maps.googleapis.com/maps/api/staticmap?format=gif&amp;]
        map_img += %Q[center=#{lat},#{lon}&amp;zoom=14&amp;size=200x200&amp;markers=#{lat},#{lon}&amp;]
        map_img += %Q[key=#{google_maps_api_key}&amp;sensor=false"]
      end
      map_link = %Q[<a href="#{eval(map_link_url)}">]
      map_link += %Q[MAP]
      map_link += %Q[<img class="map" src=#{map_img}>] if map_img
      map_link += "</a>"
      detail += map_link
    end
    detail += "</p>"
  end

  img = %Q[<img class="#{place}" src="#{@image_url}/#{image}" alt="#{alt}" title="#{alt}" #{size}>]
  img_t = %Q[<img class="#{place}" src="#{@image_url}/#{image_t}" alt="#{alt}" title="#{alt}" #{size}>]

  url  = ''

  url += %Q[<div class="photo_detail">]
  url += %Q[<a href="#{@image_url}/#{image}">]
  url += thumbnail ? img_t : img
  url += %Q[</a>]
  url += %Q[#{detail}] if detail
  url += %Q[</div>]

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
    @conf['mage_gps.google_maps_api_key'] = @cgi.params['image_gps.google_maps_api_key'][0]
    @conf['image_gps.show_exif_info'] = @cgi.params['image_gps.show_exif_info'][0]
    @conf['image_gps.map_link_url'] = @cgi.params['image_gps.map_link_url'][0]
  end

  <<-HTML
    <div>
    <h3>Google Static Maps API Key</h3>
    <input type="text" name="image_gps.google_maps_api_key" value="#{@conf['image_gps.google_maps_api_key']}">
    </div>
    <div>
    <h3>Show Exif Info</h3>
    <input type="text" name="image_gps.show_exif_info" value="#{@conf['image_gps.show_exif_info']}">
    <p>EXIFのタグ名をスペース区切りで設定します。</p>
    <p>exp.)Model FocalLength FNumber ExposureTime ExposureBiasValue</p>
    </div>
    <div>
    <h3>Map Link URL</h3>
    <input type="text" name="image_gps.map_link_url" id="map_link_url" value="#{@conf['image_gps.map_link_url']}">
    <p>地図サイトへのリンクURLを設定します。空欄の場合、Googleマップへリンクされます。</p>
    <p>パラメータとして\#{lat},\#{lon}が使用できます。それぞれ緯度、経度に展開されます。</p>
    <p>下のセレクタから選択すると各サービスのデフォルト値が設定されます。</p>
    <select name="map_url" id="map_url" onChange="document.getElementById('map_link_url').value=this.value">
      <option value="" selected disabled>--select service--</option>
      <option value="http://maps.google.co.jp//maps/m?q=\#{lat},\#{lon}">Googleマップ</option>
      <option value="http://maps.loco.yahoo.co.jp/maps?p=lat=\#{lat}&lon=\#{lon}&ei=utf-8">Yahoo地図</option>
      <option value="http://www.mapion.co.jp/m/\#{lat}_\#{lon}_9">マピオン</option>
      <option value="http://www.bing.com/maps/?v=2&cp=\#{lat}~\#{lon}&lvl=15">Bing Maps</option>
    </select>
    </div>
  HTML
end
