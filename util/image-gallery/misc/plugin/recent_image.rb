# recent_image.rb  $Revision: 2.0.2 $
#
# Copyright (c) 2005-2010 N.KASHIJUKU <n-kashi[at]whi.m-net.ne.jp>
# You can redistribute it and/or modify it under GPL2.
#
#  http://www1.whi.m-net.ne.jp/n-kashi/recent_image.htm
#

eval( <<MODIFY_CLASS, TOPLEVEL_BINDING )
module TDiary
  class TDiaryMonth
    attr_reader :diaries
  end
end
MODIFY_CLASS

eval( <<MODIFY_CLASS, TOPLEVEL_BINDING )
module TDiary
  class ImageData
    attr_reader :file, :url, :title, :subtitle, :date, :width, :height, :type
    attr_writer :file, :url, :title, :subtitle, :date, :width, :height, :type
  end
end
MODIFY_CLASS

unless Array.respond_to?( 'randomize' )
  eval( <<-MODIFY_CLASS, TOPLEVEL_BINDING )
  class Array
    def randomize
      arr = dup
      collect{ arr.slice!(rand(arr.length)) }
    end
  end
  MODIFY_CLASS
end

@recent_image_dir = @options && @options['image.dir'] || './images/'
@recent_image_dir.chop! if /\/$/ =~ @recent_image_dir
@recent_image_url = @options && @options['image.url'] || './images/'
@recent_image_url.chop! if /\/$/ =~ @recent_image_url
@recent_imageex_yearlydir = @options && @options['image_ex.yearlydir'] || 0

@recent_image_hash = Hash[]      # the Hash table. "<yyyymmdd>_<n>" => ImageData Objects
@recent_image_keys = []          # sorted keys of '@recent_image_hash'
@recent_image_rkeys = []         # reverse sorted keys of '@recent_image_hash'

@recent_image_use_cache = true
@recent_image_show_exif = @options['image-gallery.show_exif']
@recent_image_show_exif = false if @recent_image_show_exif == nil
@recent_image_cache = "#{@cache_path}/gallery/image-gallery2.dat"

@recent_image_imgre = /[^_]image(?:_left|_right|_gps)?\s*\(?\s*([0-9]*)\s*\,?\s*[\"']([^'\"]*)[\"']/

#  Local Functions

# Search 'image' directory(s) and return a hash table.
#     "yyyymmdd_nn" => "File name" (or Thmbnail's File name)
def get_filehash_rcimg(target)
  f_imghash = Hash[]

  f_list = Dir.glob(%Q[#{@recent_image_dir}/**/#{target}].untaint)
  f_list = f_list + Dir.glob(%Q[#{@recent_image_dir}/**/s#{target}].untaint) if target != "*"
  f_list.each do |f_name|
    b_name = File.basename(f_name)
    next unless b_name.match("^([0-9]{8}_[0-9]+)\..+")
    tmb_name = %Q[#{File.dirname(f_name)}/s#{b_name}]
    file = (f_list.include?(tmb_name) ?  tmb_name : f_name)
    f_imghash[$1] = (@recent_imageex_yearlydir == 1 ? %Q[#{$1[0,4]}/#{File.basename(file)}] : File.basename(file))
  end

  return f_imghash
end


def image_info_rcimg( filename )
  image_type = nil
  image_height = nil
  image_width = nil

  f = File.open(filename.untaint, "rb")
  return image_type, image_height, image_width if f == nil

  sig = f.read( 24 )
  if /\A\x89PNG\x0D\x0A\x1A\x0A(....)IHDR(........)/on =~ sig
    image_type = 'png'
    image_width, image_height = $2.unpack( 'NN' )

  elsif /\AGIF8[79]a(....)/on =~ sig
    image_type   = 'gif'
    image_width, image_height = $1.unpack( 'vv' )

  elsif /\A\xFF\xD8/on =~ sig
    image_type = 'jpg'
    data = $'

    until data.empty?
      if RUBY_VERSION >= '1.9.0' 
        break if data[0].unpack("C").first != 0xFF
        break if data[1].unpack("C").first == 0xD9
      else
        break if data[0] != 0xFF
        break if data[1] == 0xD9
      end

      data_size = data[2,2].unpack( 'n' ).first + 2
      datax   = data[1]
      datax_s = [0xc0, 0xc1, 0xc2, 0xc3, 0xc5, 0xc6, 0xc7, 0xc9, 0xca, 0xcb, 0xcd, 0xce, 0xcf]
      if RUBY_VERSION >= '1.9.0'
        datax   = data[1].unpack("C").first
        datax_s = [0xc0]
      end

      if datax_s.index(datax) != nil
        image_height, image_width = data[5,4].unpack('nn')
        break
      else
        if data.size < data_size
          f.seek(data_size - data.size, IO::SEEK_CUR)
          data = ''
        else
          data = data[data_size .. -1]
        end
        data << f.read( 128 ) if data.size <= 4
      end
    end
  end

  f.close
  return image_type, image_height, image_width
end



# Make sorted keys of @recent_image_hash
def keysort_rcimg
  sortproc = Proc.new {|a, b|
    a.gsub(/_(\d+)/) {"_%05d" % $1.to_i} <=>
    b.gsub(/_(\d+)/) {"_%05d" % $1.to_i}
  }

  @recent_image_keys  = @recent_image_hash.keys.sort(&sortproc)
  @recent_image_rkeys = @recent_image_keys.reverse
end


def load_cache_rcimg
  db = PStore.new(@recent_image_cache)
  db.transaction(true) do
    @recent_image_hash = db["recent_image_hash"]
    @recent_image_keys = db["recent_image_keys"]
    @recent_image_rkeys= db["recent_image_rkeys"]
    db.abort
  end
end


def save_cache_rcimg
  return if @recent_image_hash.length == 0

  cache_dir = File.dirname( @recent_image_cache )
  Dir.mkdir(cache_dir) unless File.directory?(cache_dir)

  db = PStore.new(@recent_image_cache)
  db.transaction do
    db["recent_image_hash"]  = @recent_image_hash
    db["recent_image_keys"]  = @recent_image_keys
    db["recent_image_rkeys"] = @recent_image_rkeys
    db["recent_image_dir"]   = @recent_image_dir
    db["recent_image_url"]   = @recent_image_url
    db.commit
    db.abort
  end
end


def make_image_hash_rcimg
  f_imghash = Hash[]
  f_imghash = get_filehash_rcimg("*")

  cgi = CGI::new
  def cgi.referer; nil;
  end

  @years.keys.sort.reverse_each do |year|
    @years[year].sort.reverse_each do |month|
      cgi.params['date'] = ["#{year}#{month}"]
      m = TDiaryMonth::new(cgi, '', @conf)
      m.diaries.keys.sort.reverse_each do |date|
        next unless m.diaries[date].visible?
        m.diaries[date].each_section do |section|
          subtitle = ""
          subtitle = section.subtitle.gsub(/[<{](.*?)[}>]/,'') if section.subtitle
          search_img_rcimg(date, section.subtitle, subtitle, f_imghash)
          search_img_rcimg(date, section.body,     subtitle, f_imghash)
        end
      end
    end
  end
end

def search_img_rcimg(date, body, subtitle, f_imghash)
  body.to_s.scan(@recent_image_imgre).each do |num, title|   # Search "image plugin" in all diaries
    f_name = f_imghash[%Q[#{date}_#{num}]]                              #  and pick up params. -> image[0]=number, image[1]=title
    next if f_name == nil
    begin
      type, height, width = image_info_rcimg(%Q[#{@recent_image_dir}/#{f_name.delete("s")}])
      image = ImageData.new
      image.url   = f_name
      image.file  = f_name.delete("s")
      image.date  = date
      image.title = title
      image.subtitle = subtitle
      image.type  = type
      image.height = height
      image.width = width
      @recent_image_hash[%Q[#{date}_#{num}]] = image
    rescue
    end
  end
end

#  Initial Function ... Make a hash table : "<yyyymmdd>_<n>" => ["Filename", "title"]
def init_rcimg
  return if @recent_image_hash != nil and @recent_image_hash.length != 0
  return unless @mode == 'day' or @mode == 'month' or @mode == 'latest' or @mode == 'preview' or @mode == 'nyear'

  if @recent_image_use_cache and File.exist?(@recent_image_cache)
    load_cache_rcimg
  else
    make_image_hash_rcimg
    keysort_rcimg
    if @recent_image_use_cache
      save_cache_rcimg 
    end
  end
end

#  PLUGIN body
#   recent_image()
#
def recent_image(items = 4, width = 80, link_mode = 1, name_filter = nil, title_filter = nil, reverse = false, random = false)
  items = items.to_i
  images = []
  keys = []

  init_rcimg

  return ("") if items == -1

  keys = (random ? @recent_image_keys.randomize : (reverse ? @recent_image_keys : @recent_image_rkeys))

  catch(:exit) {
    keys.each do |key|
      image = @recent_image_hash[key]
      next if name_filter  != nil and image.file.match(name_filter) == nil
      next if title_filter != nil and image.title.match(title_filter) == nil
      images.push(image)
      if items != 0
        throw :exit if items == images.length
      end
    end
  }

  result = %Q[<div class="recentimage">\n]
  images.each do |image|
    if image.height.to_i > image.width.to_i
      sizestr = %Q[width="#{width*image.width.to_i/image.height.to_i}" height="#{width}"]
    else
      sizestr = %Q[width="#{width}" height="#{width*image.height.to_i/image.width.to_i}"]
    end
    case link_mode
    when 0
      result << %Q[<a href="./image-gallery.rb?mode=viewer;key=#{File.basename(image.file, ".*")}"><img src="#{@recent_image_url}/#{image.url}" #{sizestr} alt="#{image.title}" title="#{image.title}"></a>\n]
    when 1
      result << %Q[<a href="./?date=#{image.date}"><img src="#{@recent_image_url}/#{image.url}" #{sizestr} alt="#{image.title}" title="#{image.title}"></a>\n]
    when 2
      result << %Q[<a href="#{@recent_image_url}/#{image.file}"><img src="#{@recent_image_url}/#{image.url}" #{sizestr} alt="#{image.title}" title="#{image.title}"></a>\n]
    when 3
      result << %Q[<a onclick="window.open(this.href, '_recent_image', 'scrollbars=no,resizable=yes,toolbar=no,directories=no,location=no,menubar=no,status=no,left=0,top=0'); return false" href="#{@recent_image_url}/#{image.file}"><img src="#{@recent_image_url}/#{image.url}" #{sizestr} alt="#{image.title}" title="#{image.title}"></a>\n]
    when Array
      result << %Q[<a onclick="window.open(this.href, '_recent_image', 'width=#{link_mode[1]},height=#{link_mode[2]},scrollbars=no,resizable=yes,toolbar=no,directories=no,location=no,menubar=no,status=no,left=0,top=0'); return false" href="#{@recent_image_url}/#{image.file}"><img src="#{@recent_image_url}/#{image.url}" #{sizestr} alt="#{image.title}" title="#{image.title}"></a>\n] if link_mode[0] == 3
    else
    end
  end
  result << "</div>"
end


# PLUGIN body
#    count_image()
#
def count_image(name_filter = nil, title_filter = nil)
  count = 0
  init_rcimg

  if name_filter == nil and title_filter == nil
    count = @recent_image_keys.length 
  else
    @recent_image_keys.each do |key|
      image = @recent_image_hash[key]
      next if name_filter  != nil and image.file.match(name_filter) == nil
      next if title_filter != nil and image.title.match(title_filter) == nil
      count = count + 1
    end
  end

  count.to_s.reverse.gsub(/\d\d\d/, '\0,').reverse.sub(/^([-]{0,1}),/, '\1')
end


# PLUGIN body
#     view_exif() ... input EXIF datas of images in your diary.
#
def view_exif(id = 0, exifparam ="")
  init_rcimg if @recent_image_hash == nil or @recent_image_hash.length == 0
  begin
    require 'exifparser'

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

# this is for view_exif().
add_body_enter_proc(Proc.new do |date| 
  @image_date_exif = date.strftime("%Y%m%d")
  ""
end)

#  Update Proc of the plugin
add_update_proc do
  f_imghash = Hash[]

  if @recent_image_hash.length == 0
    if @recent_image_use_cache
      load_cache_rcimg
    else
      make_image_hash_rcimg
    end
  end

  date = @date.strftime('%Y%m%d')
  @recent_image_hash.keys.each do |key|     # Clear all data of the day in @recent_image_hash
    if key.include?(date)
      @recent_image_hash.delete(key)
    end
  end

  diary = @diaries[date]
  if diary.visible?
    f_imghash = get_filehash_rcimg(%Q|#{date}_*|)
    diary.each_section do |section|
      subtitle = ""
      subtitle = section.subtitle.gsub(/[<{](.*?)[}>]/,'') if section.subtitle
      search_img_rcimg(date, section.subtitle, subtitle, f_imghash)
      search_img_rcimg(date, section.body,     subtitle, f_imghash)
    end
  end

  keysort_rcimg
  save_cache_rcimg if @recent_image_use_cache
end


# for SmoothGallery (SildeShow mode of 'tDiary Image Gallery')
if /image-gallery\.(?:cgi|rb)$/ =~ $0
  add_header_proc do
<<EOS
	<link rel="stylesheet" href="js/SmoothGallery/css/jd.gallery.css" type="text/css" media="screen" charset="utf-8" />
	<link rel="stylesheet" href="js/SmoothGallery/css/ReMooz.css" type="text/css" media="screen" charset="utf-8" />
	<link rel="stylesheet" href="#{theme_url}/image-gallery.css" type="text/css" media="all">
	<script src="js/SmoothGallery/scripts/mootools-1.2.1-core-yc.js" type="text/javascript"></script>
	<script src="js/SmoothGallery/scripts/mootools-1.2-more.js" type="text/javascript"></script>
	<script src="js/SmoothGallery/scripts/ReMooz.js" type="text/javascript"></script>
	<script src="js/SmoothGallery/scripts/jd.gallery.js" type="text/javascript"></script>
EOS
  end
end
