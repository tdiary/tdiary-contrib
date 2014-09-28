# view_exif.rb  $Revision: 1.0.0 $
#
# Copyright (c) 2013 N.KASHIJUKU <n-kashi[at]whi.m-net.ne.jp>
# You can redistribute it and/or modify it under GPL2.
#
#  http://www1.whi.m-net.ne.jp/n-kashi/recent_image.htm
#
# !caution! view_exif.rb needs recent_image.rb
#
require 'exifparser'

# PLUGIN body
#     view_exif() ... input EXIF datas of images in your diary.
#
def view_exif(id = 0, exifparam ="")
  init_rcimg if @recent_image_hash == nil or @recent_image_hash.length == 0

  begin
    @image_date_exif ||= @date.strftime("%Y%m%d")
    @exifparser = ExifParser.new(%Q[#{@image_dir}/#{@recent_image_hash[@image_date_exif+"_"+id.to_s].file}].untaint)

    if exifparam == ""    # return a formatted string.
      model             = @exifparser['Model'].to_s
      focallength       = @exifparser['FocalLength'].to_s
      fnumber           = @exifparser['FNumber'].to_s
      exposuretime      = @exifparser['ExposureTime'].to_s
      isospeedratings   = @exifparser['ISOSpeedRatings'].to_s
      exposurebiasvalue = @exifparser['ExposureBiasValue'].to_s
      if @exifparser.tag?('LensParameters')
        lensname        = "("+ @exifparser['LensParameters'].to_s + ")"
      else
        lensname        = ""
      end
      return %Q[<div class="exifdatastr"><p>#{model}, #{focallength}, #{fnumber}, #{exposuretime}, ISO#{isospeedratings}, #{exposurebiasvalue}EV #{lensname}</p></div>]
    else                  # return the requested value.
      return @exifparser[exifparam.untaint].to_s
    end

  rescue
    exp = ($!).to_s + "<br>"
    ($!).backtrace.each do |btinfo|
      exp += btinfo
      exp += "<br>"
    end
    return exp
  end
end


#  Callback Functions

add_body_enter_proc(Proc.new do |date| 
  @image_date_exif = date.strftime("%Y%m%d")
  ""
end)
