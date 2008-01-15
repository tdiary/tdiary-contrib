# image_gps.rb $Revision: 1.5 $
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
      size = %Q| width="#{size[0].to_i}" height="#{size[1].to_i}"|
    else
      size = %Q| width="#{size.to_i}"|
    end
  else
    size = ""
  end
  
  eznavi = 'http://walk.eznavi.jp'
  mapion = 'http://www.mapion.co.jp'

  ( datum,nl,el ) = gps_info("#{@image_dir}/#{image}")
  
  if thumbnail then
    %Q[<a href="#{h @image_url}/#{h image}"><img class="#{h place}" src="#{h @image_url}/#{h image_t}" alt="#{h alt}" title="#{h alt}"#{size}></a>]
  elsif el.nil?
    %Q[<img class="#{h place}" src="#{h @image_url}/#{h image}" alt="#{h alt}" title="#{h alt}"#{size}>]
  else
  	if @conf.mobile_agent?
      lat = "#{sprintf("%d.%d.%.2f",*nl)}"
      lon = "#{sprintf("%d.%d.%.2f",*el)}"
      href = %Q[<a href="#{eznavi}/map?datum=#{datum=='TOKYO'?'1':'0'}&amp;unit=0&amp;lat=+#{lat}&amp;lon=+#{lon}">]
    else
      Wgs2Tky.conv!(nl,el) if datum =~ /WGS-?84/
      lat ="#{sprintf("%d/%d/%.3f",*nl)}"
      lon ="#{sprintf("%d/%d/%.3f",*el)}"
      href = %Q[<a href="#{mapion}/c/f?el=#{lon}&amp;nl=#{lat}&amp;scl=10000&amp;pnf=1&amp;uc=1&amp;grp=all&amp;size=500,500">]
    end
    
    href + %Q[<img class="#{h place}" src="#{h @image_url}/#{h image}" alt="#{h alt}" title="#{h alt}" #{size}></a>]
    
  end
end

require 'rexif_gps'

Jpeg.use_class_for(Jpeg::Segment::APP1,Exif)

def gps_info(fname)
  fname.untaint
  exif = Jpeg::open(fname,Jpeg::PARSE_HEADER_ONLY).app1
  
  return nil unless exif.is_exif?
  return nil unless exif.ifd0.gpsifd
  
  gps = exif.ifd0.gpsifd
  
  if( gps.latitude_ref.value=="N" && gps.longitude_ref.value=="E" && gps.map_datum.value =~ /(TOKYO|WGS-?84)/)
    return gps.map_datum.value,gps.latitude.value,gps.longitude.value
  end
rescue
end
