#!/usr/bin/env ruby
# image-gallery.rb $Revision: 2.0.1 $
#
# Copyright (c) 2005-2011 N.KASHIJUKU <n-kashi[at]whi.m-net.ne.jp>
# You can redistribute it and/or modify it under GPL2.

if FileTest::symlink?( __FILE__ ) then
  org_path = File::dirname( File::readlink( __FILE__ ) )
else
  org_path = File::dirname( __FILE__ )
end
$:.unshift( org_path.untaint )
require 'tdiary'
require 'pstore'
require 'date'


# class TDiaryGallery
#
module TDiary
  class ImageData
    attr_reader :file, :url, :title, :subtitle, :date, :width, :height, :type
    attr_writer :file, :url, :title, :subtitle, :date, :width, :height, :type
  end

  
  class TDiaryGallery < ::TDiary::TDiaryBase
    MAX_PAGES = 20
    ORDER_OPTIONS = [
    ["asc", "新しい順"],
    ["desc", "古い順"],
    ]
    MODE_OPTIONS = [
    ["list", "リスト"],
    ["slide", "スライド"],
    ]

    def initialize( cgi, rhtml, conf )
      super
      @img_version = "2.0.1"
      @image_hash = Hash[]
      @image_num = 0
      @image_keys = []
      @images = []
      @exifstr = []
      @t_page_title = ""

      get_conf(conf)
      parse_args(cgi)
      format_form
      read_cache
      make_image_data
      check_name_filter_dateformat
      make_page_title
    end

    private

    def get_conf(conf)
      @column = conf.options['image-gallery.column'].to_i
      @column = 3 if @column == 0
      @line   = conf.options['image-gallery.line'].to_i
      @line   = 4 if @line == 0
      @num = @line * @column
      @width  = conf.options['image-gallery.width']
      @width  = "160" if @width == nil
      @vwidth = conf.options['image-gallery.vwidth']
      @vwidth = "640" if @vwidth == nil 
      @show_exif = conf.options['image-gallery.show_exif']
      @show_exif = false if @show_exif == nil
      @use_mid_image = conf.options['image-gallery.use_mid_image']
      @use_mid_image = false if @use_mid_image == nil
    end

    def parse_args(cgi)
      @start = cgi["start"].to_i
      @order = @cgi["order"].empty? ? "asc" : @cgi["order"]
      @name_filter  = @cgi["name"].empty? ? "" : @cgi["name"].strip
      @title_filter = @cgi["title"].empty? ? "" : @cgi["title"].strip
      @subtitle_filter = @cgi["subtitle"].empty? ? "" : @cgi["subtitle"].strip
      @mode = @cgi["mode"].empty? ? "list" : @cgi["mode"].strip
      @mode = "list" if @mode != "viewer" and @mode != "slide" and @mode != "fslide"
      @key   = cgi["key"].empty? ? "" : cgi["key"].strip
      @page_title = cgi["pagetitle"].empty? ? "" : @cgi["pagetitle"].strip
      @show_inputfield = true;
      show_inputfield = @cgi["showinputfield"].strip
      @show_inputfield = false if show_inputfield == "false"
    end

    def read_cache
      db = PStore.new("#{cache_path}/gallery/image-gallery2.dat")
      db.transaction do
        @image_hash = db["recent_image_hash"]
        @image_keys = db["recent_image_keys"]
        @image_url  = db["recent_image_url"]
        @image_dir  = db["recent_image_dir"]
        db.abort
      end
    end

    def make_image_data
      if @name_filter != "" or @title_filter != "" or @subtitle_filter != ""
        @image_keys.reject! { |key|
          image = @image_hash[key]
          (@name_filter  != "" and image.file.match(@name_filter) == nil) or
          (@title_filter != "" and image.title.match(@title_filter) == nil) or
          (@subtitle_filter != "" and image.subtitle.match(@subtitle_filter) == nil)
        }
      end
      @image_num = @image_keys.length
      @image_keys = @image_keys.reverse if @order == "asc"

      if @mode == "list" or @mode == "slide" or @mode == "fslide"
        if @key != ""
          index = @image_keys.index(@key)
          if index != nil
            @start = (index / @num) * @num
          else
            return
          end
        end
        @num.times do |i|
          index = @start + i
          break if @image_keys[index] == nil
          @images.push(@image_hash[@image_keys[index]])
        end
      elsif @mode == "viewer"
        if @key != ""
          index = @image_keys.index(@key)
          if index != nil
            @start = index
          else
            @start = 0
          end
        end
        @images.push(@image_hash[@image_keys[@start]])
        width, height = @images[0].width.to_i, @images[0].height.to_i
        size = ((width > height ? width : height) > @vwidth.to_i) ? @vwidth : width
        if width > height
          @sizestr = %Q[width="#{size}" height="#{(size.to_i*height/width).to_s}"]
        else
          @sizestr = %Q[width="#{(size.to_i*width/height).to_s}" height="#{size}"]
        end
        if @show_exif and @images[0].type == "jpg"
          begin
            require 'exifparser'
            @exifstr = read_exif_data("#{@image_dir}/#{@images[0].file}")
          rescue
            exp = []
            exp.push(($!).to_s)
            ($!).backtrace.each do |btinfo|
              exp.push(btinfo)
            end
            @exifstr = exp
          end
        end
      end
    end

    def check_name_filter_dateformat
      @page_year  = ""
      @page_month = ""
      @page_day   = ""
      @page_date  = nil
      return if @name_filter == ""
      begin
        if @name_filter.index(/[\d]{8}/) != nil
          @page_year  = @name_filter[0,4]
          @page_month = @name_filter[4,2]
          @page_day   = @name_filter[6,2]
          @page_date  = Date.new(@page_year.to_i, @page_month.to_i, @page_day.to_i)

        elsif @name_filter.index(/[\d]{6}/) != nil
          @page_year  = @name_filter[0,4]
          @page_month = @name_filter[4,2]
          @page_date  = Date.new(@page_year.to_i, @page_month.to_i, 1)

        elsif @name_filter.index(/[\d]{4}/) != nil
          @page_year  = @name_filter[0,4]
          @page_date  = Date.new(@page_year.to_i, 1, 1)
        end
      rescue
        @page_year  = ""
        @page_month = ""
        @page_day   = ""
        @page_date  = nil
        return
      end
    end

    def make_page_title
      return if @page_title == ""
      @t_page_title = String.new(@page_title)
      @t_page_title.gsub!("@year",  @page_year)
      @t_page_title.gsub!("@month", @page_month)
      @t_page_title.gsub!("@day",   @page_day)
      begin
        @t_page_title.gsub!("@subtitle", @images[0].subtitle)
      rescue
      end
    end
    
    def format_links(count)
      page_count = (count - 1) / @num + 1
      current_page = @start / @num + 1
      first_page = current_page - (MAX_PAGES / 2 - 1)
      if first_page < 1
        first_page = 1
      end
      last_page = first_page + MAX_PAGES - 1
      if last_page > page_count
        last_page = page_count
      end
      buf = "<p id=\"navi\" class=\"infobar\">\n"
      if current_page > 1
        buf << format_link("&laquo;先頭へ&nbsp;", 0, 0, @mode)
        buf << format_link("&lt;前へ", @start - @num, @num, @mode)
      end
      if first_page > 1
        buf << "... "
      end
      for i in first_page..last_page
        if i == current_page
          buf << "#{i} "
        else
          buf << format_link(i.to_s, (i - 1) * @num, @num, @mode)
        end
      end
      if last_page < page_count
        buf << "... "
      end
      if current_page < page_count
        buf << format_link("次へ&gt;", @start + @num, @num, @mode)
        buf.concat(format_link("&nbsp;最後へ&raquo;", (page_count - 1) * @num, 0, @mode))
      end
      buf << "</p>\n"
      return buf
    end

    def format_link(label, start, num, mode)
      return format('<a href="%s?mode=%s;%sstart=%d">%s</a> ',
              _(@cgi.script_name ? @cgi.script_name : ''),
              mode,
              make_cgi_param,
              start, label)
    end

    def format_links_viewer
      buf = "<p id=\"vnavi\" class=\"infobar\">\n"
      if @start == 0
        buf << "&laquo;前へ"
      else
        buf << format_link_viewer("&laquo;前へ", @image_keys[@start - 1])
      end
      buf << "&nbsp;&nbsp;|&nbsp;&nbsp;"
      buf << format_link("一覧へ", (@start / @num) * @num, 0, "list")
      buf << "&nbsp;&nbsp;|&nbsp;&nbsp;"
      if @start == @image_keys.length - 1
        buf << "次へ&raquo;"
      else
        buf << format_link_viewer("次へ&raquo;", @image_keys[@start + 1])
      end
      buf << "</p>\n"
      return buf
    end

    def format_link_viewer(label, key)
      return format('<a href="%s?%smode=viewer;key=%s">%s</a>',
              _(@cgi.script_name ? @cgi.script_name : ''),
              make_cgi_param,
              key, label)
    end

    def format_link_viewer_image(key)
      return format('%s?%smode=viewer;key=%s',
              _(@cgi.script_name ? @cgi.script_name : ''),
              make_cgi_param,
              key)
    end

    def format_links_date
      return "" unless @name_filter != "" and @title_filter == "" and  @subtitle_filter == ""

      begin
        buf = "<p id=\"ynavi\" class=\"infobar\">\n"
        if @page_day != ""
          yesterday = (@page_date - 1).strftime("%Y%m%d")
          tomorrow  = (@page_date + 1).strftime("%Y%m%d")
          buf << format_link_date(%Q[&laquo;#{(@page_date - 1).to_s}], yesterday)
          buf << format('&nbsp;&nbsp;|&nbsp;&nbsp;<a href="%s?mode=%s;order=%s">%s</a>&nbsp;&nbsp;|&nbsp;&nbsp;', _(@cgi.script_name ? @cgi.script_name : ''), _(@mode), _(@order), '全画像')
          buf << format_link_date(%Q[#{(@page_date + 1).to_s}&raquo;], tomorrow)

        elsif @page_month != ""
          prevmonth = (@page_date << 1).strftime("%Y%m")
          nextmonth = (@page_date >> 1).strftime("%Y%m")
          buf << format_link_date(%Q[&laquo;#{(@page_date << 1).to_s[0,7]}], prevmonth)
          buf << format('&nbsp;&nbsp;|&nbsp;&nbsp;<a href="%s?mode=%s;order=%s">%s</a>&nbsp;&nbsp;|&nbsp;&nbsp;', _(@cgi.script_name ? @cgi.script_name : ''), _(@mode), _(@order), '全画像')
          buf << format_link_date(%Q[#{(@page_date >> 1).to_s[0,7]}&raquo;], nextmonth)

        elsif @page_year != ""
          year = @page_year.to_i
          buf << format_link_date(%Q[&laquo;#{(year - 1).to_s}], (year - 1).to_s)
          buf << format('&nbsp;&nbsp;|&nbsp;&nbsp;<a href="%s?mode=%s;order=%s">%s</a>&nbsp;&nbsp;|&nbsp;&nbsp;', _(@cgi.script_name ? @cgi.script_name : ''), _(@mode), _(@order), '全画像')
          buf << format_link_date(%Q[#{(year + 1).to_s}&raquo;], (year + 1).to_s)
        end

        buf << "</p>\n"
        return buf
      rescue
        return ""
      end
    end

    def format_link_date(label, name_filter)
      cgi_params = make_cgi_param
      if cgi_params.gsub!(/name=[^;]*;/, "name=#{CGI::escape(name_filter)};") == nil
        cgi_params = "name=" + CGI::escape(name_filter) + ";" + cgi_params
      end
      return format('<a href="%s?mode=%s;%s">%s</a>',
              _(@cgi.script_name ? @cgi.script_name : ''),
              @mode,
              cgi_params,
              label)
    end

    def format_link_viewer_date(label, name_filter)
      return format('<a href="%s?mode=list;order=desc;name=%s">%s</a>',
              _(@cgi.script_name ? @cgi.script_name : ''),
              name_filter,
              label)
    end

    def format_link_viewer_category(subtitle)
      buf = ""
      subtitle.scan(/\[[^\]]*\]/).each do |category|
        tag = category[1..-2]
        next if tag[0] == ?[
        buf << format('[<a href="%s?mode=list;order=desc;subtitle=%s">%s</a>]',
              _(@cgi.script_name ? @cgi.script_name : ''),
              CGI::escape("\\[" + tag + "\\]"), tag)
      end
      return buf
    end

    def format_link_list_category(images)
      categories = []
      images.each do |image|
        categories |= image.subtitle.scan(/\[[^\]]*\]/)
      end
      buf = ""
      categories.each do |category|
        tag = category[1..-2]
        next if tag[0] == ?[
        buf << format('[<a href="%s?mode=list;order=desc;subtitle=%s">%s</a>]',
              _(@cgi.script_name ? @cgi.script_name : ''),
              CGI::escape("\\[" + tag + "\\]"), tag)
      end
      return buf
    end

    def get_other_mode_link
      case @mode
      when "list"
        format_link("[SLIDESHOW]", @start, @num, "slide") + format_link("[SLIDESHOW(FullScreen)]", @start, @num, "fslide")
      when "slide"
        format_link("[LIST]", @start, @num, "list") + format_link("[SLIDESHOW(FullScreen)]", @start, @num, "fslide")
      when "fslide"
        format_link("[LIST]", @start, @num, "list") + format_link("[SLIDESHOW]", @start, @num, "slide")
      end
    end

    def make_cgi_param
      buf = ""
      buf << "name=#{CGI::escape(@name_filter)};"         if @name_filter != ""
      buf << "title=#{CGI::escape(@title_filter)};"       if @title_filter != ""
      buf << "subtitle=#{CGI::escape(@subtitle_filter)};" if @subtitle_filter != ""
      buf << "pagetitle=#{CGI::escape(@page_title)};"     if @page_title != ""
      buf << "showinputfield=false;" if not @show_inputfield
      buf << "order=#{@order};"
      return buf
    end

    def format_options(options, value)
      return options.collect { |val, label|
        if val == value
          "<option value=\"#{_(val)}\" selected>#{_(label)}</option>"
        else
          "<option value=\"#{_(val)}\">#{_(label)}</option>"
        end
      }.join("\n")
    end

    def format_form
      @order_options = format_options(ORDER_OPTIONS, @order)
      @mode_options  = format_options(MODE_OPTIONS,  @mode )
    end

    def _(str)
      CGI::escapeHTML(str)
    end

    def read_exif_data(file)
      exifstr = []
      str = ""
      exif = ExifParser.new(file)
      return exifstr if exif == nil

      exifstr.push("-- IFD0 (main image) --")
      exif.each(:IFD0) do |tag|
        next if tag.name == "Unknown"
        str = "#{tag.name} : #{tag.to_s}"
        exifstr.push(str)
      end

      exifstr.push("-- Exif SubIFD --")
      exif.each(:Exif) do |tag|
        next if tag.name == "Unknown"
        str = "#{tag.name} : #{tag.to_s}"
        exifstr.push(str)
      end

      exifstr.push("-- MakerNote --")
      exif.each(:MakerNote) do |tag|
        next if tag.name == "Unknown" or tag.name == "NikonCameraSerialNumber"
        str = "#{tag.name} : #{tag.to_s}"
        exifstr.push(str)
      end

      exifstr.push("-- GPS --")
      exif.each(:GPS) do |tag|
        next if tag.name == "Unknown"
        str = "#{tag.name} : #{tag.to_s}"
        exifstr.push(str)
      end

      return exifstr

    end


    def js_start_gallery
      if @mode == "fslide"
      <<-EOS
      <script type="text/javascript">
      function startGallery() {
        var myGallery = new gallery($('myGallery'), {
          timed: true,
          fullScreen: true
        });
      }
      window.addEvent('domready',startGallery);
      </script>
      EOS
      elsif @mode == "slide"
      <<-EOS2
      <script type="text/javascript">
      function startGallery() {
        var myGallery = new gallery($('myGallery'), {
          timed: true,
        });
      }
      window.addEvent('domready',startGallery);
      </script>
      EOS2
      end
    end
  end
end

begin
  @cgi = CGI::new
  if TDiary::Config.instance_method(:initialize).arity == 0
    # for tDiary 2.0 or earlier
    conf = TDiary::Config::new
  else
    # for tDiary 2.1 or later
    conf = TDiary::Config::new(@cgi)
  end
  tdiary = TDiary::TDiaryGallery::new( @cgi, 'gallery.rhtml', conf )

  head = {
    'type' => 'text/html',
    'Vary' => 'User-Agent'
  }
  body = tdiary.eval_rhtml
  head['charset'] = conf.encoding
  head['Content-Length'] = body.size.to_s
  head['Pragma'] = 'no-cache'
  head['Cache-Control'] = 'no-cache'

  print @cgi.header( head )
  print body
rescue Exception
  if @cgi then
    print @cgi.header( 'type' => 'text/plain' )
  else
    print "Content-Type: text/plain\n\n"
  end
  puts "#$! (#{$!.class})"
  puts ""
  puts $@.join( "\n" )
end
