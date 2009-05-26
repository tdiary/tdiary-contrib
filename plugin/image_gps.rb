# image_gps.rb $Revision: 1.6 $
# 
# 概要:
# 画像にGPSによる位置情報が含まれている場合は、対応する地図へのリンクを生成する。
#
# 使い方:
# 絵日記Plugin(image.rb)とおなじ
#
# Copyright (c) 2004,2005 kp <kp@mmho.no-ip.org>
# Distributed under the GPL
#

=begin ChangeLog
2009-05-26 kp
  * walk.eznavi.jpの場合のクエリを修正
  * リンク先をgoogle mapに
  * wgs2tkyを使用しない
2008-05-22 kp
  * MapDatumがTOKYO以外の場合、WGS-84と類推する
2008-01-17 kp
  * いろいろ変更
2006-03-28 kp
  * cooperation with ALPSLAB clip
2006-03-27 kp
  * use exifparser
2005-07-25 kp
  * correct link url when access with mobile.
2005-07-19 kp
  * MapDatum macth to WGS84
2005-05-25 kp
  * correct url link to mapion.
2005-05-24 kp
  * create link to http://walk.eznavi.jp when access with mobile.
2004-11-30 kp
  * first version
=end

require 'wgs2tky'
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
  
  eznavi = 'http://walk.eznavi.jp'
  mapion = 'http://www.mapion.co.jp'
  google = 'http://maps.google.co.jp'

  exif = ExifParser.new("#{@image_dir}/#{image}".untaint) rescue nil
  
  el = nil
  nl = nil
  datum = nil

  alt_org = alt
  if exif
    if @conf['image_gps.add_info']
      alt += ' '+exif['Model'].to_s if exif.tag?('Model')
      alt += ' '+exif['FocalLength'].to_s if exif.tag?('FocalLength')
      alt += ' '+exif['ExposureTime'].to_s if exif.tag?('ExposureTime')
      alt += ' '+exif['FNumber'].to_s if exif.tag?('FNumber')
    end
    begin
      lat = exif['GPSLatitude'].value
      lat = lat[0].to_f + lat[1].to_f/60 + lat[2].to_f/3600
      lat = -lat if exif['GPSLatitudeRef'].value == 'S'
      lon = exif['GPSLongitude'].value
      lon = lon[0].to_f + lon[1].to_f/60 + lon[2].to_f/3600
      lon = -lon if exif['GPSLongitudeRef'].value == 'W'
      datum = exif['GPSMapDatum'].value if exif.tag?('GPSMapDatum')
    rescue
      lat = nil
    end
  end

  unless lat.nil? && @conf.mobile_agent? 
    lat,lon = tky2wgs(lat,lon) if datum == 'TOKYO'
  end

  if thumbnail
    url = %Q[<a href="#{@image_url}/#{image}"><img class="#{place}" src="#{@image_url}/#{image_t}" alt="#{alt}" title="#{alt}"#{size}></a>]
  elsif lat.nil?
    url = %Q[<img class="#{place}" src="#{@image_url}/#{image}" alt="#{alt}" title="#{alt}"#{size}>]
  else
    if @conf.mobile_agent?
      url = %Q[<a href="#{eznavi}/map?datum=#{datum=='TOKYO'?'1':'0'}&amp;unit=0&amp;lat=+#{lat}&amp;lon=+#{lon}">]
    else
      url = %Q[<a href="#{google}/maps?q=#{lat},#{lon}">]
    end
    url += %Q[<img class="#{place}" src="#{@image_url}/#{image}" alt="#{alt}" title="#{alt}" #{size}></a>]
  end
  url
end

add_conf_proc('image_gps','image_gpsの設定','etc') do
  if @mode == 'saveconf' then
    @conf['image_gps.add_info'] = @cgi.params['image_gps.add_info'][0]
  end
  
  <<-HTML
    <p>
    <h3>撮影条件の表示</h3>
    <input type="checkbox" name="image_gps.add_info" value="true" #{if @conf['image_gps.add_info'] then " checked" end}>タイトルに撮影条件を追加する</p>
  HTML

end
