# show photo image on Flickr.com
#
# usage:
#   flickr(photo_id[, size[, place]])
#     - photo_id: The id of the photo to show.
#     - size: Size of photo. (optional)
#       Choose from square, thumbnail, small, medium, or large.
#     - place: class name of img element. default is 'flickr'.
#
#   flickr_left(photo_id[, size])
#
#   flickr_right(photo_id[, size])
#
# options configurable through settings:
#   @conf['flickr.apikey'] : a key for access Flickr API
#   @conf['flickr.default_size'] : default image size
#
# Copyright (c) MATSUOKA Kohei <http://www.machu.jp/>
# Distributed under the GPL
#
require 'open-uri'
require 'md5'
require 'rexml/document'

def flickr(photo_id, size = nil, place = 'flickr')
  unless @conf['flickr.apikey'] || @conf['flickr.apikey'].empty?
    return '[ERROR] flickr.rb: API Key is not specified.'
  end
  size ||= @conf['flickr.default_size'] || 'small'
  photo = flickr_photo_info(photo_id.to_s, size)
  unless photo
    return '[ERROR] flickr.rb: failed to get photo.'
  end

  if @cgi.mobile_agent?
    body = %Q|<a href="#{photo[:src]}">#{photo[:title]}</a>|
  else
    body = %Q|<a href="#{photo[:page]}"><img title="#{photo[:title]}" alt="#{photo[:title]}" src="#{photo[:src]}" class="#{place}"|
    body << %Q| width="#{photo[:width]}"| if photo[:width]
    body << %Q| height="#{photo[:height]}"| if photo[:height]
    body << %Q|></a>|
  end

  @flickr_encoder.call(body)
end

def flickr_left(photo_id, size = nil)
  flickr(photo_id, size, 'left')
end

def flickr_right(photo_id, size = nil)
  flickr(photo_id, size, 'right')
end

def flickr_photo_info(photo_id, size)
  photo = {}

  begin
    flickr_open('flickr.photos.getInfo', photo_id) {|f|
      res = REXML::Document.new(f)
      photo[:page]  = res.elements['//rsp/photo/urls/url'].text
      photo[:title] = res.elements['//rsp/photo/title'].text
    }
    flickr_open('flickr.photos.getSizes', photo_id) {|f|
      res = REXML::Document.new(f)
      res.elements.each('//rsp/sizes/size') do |s|
        if s.attributes['label'].downcase == size.downcase
          photo[:src] = s.attributes['source']
          photo[:width] = s.attributes['width']
          photo[:height] = s.attributes['height']
        end
      end
    }
  rescue Exception => e
    return nil
  end
  photo
end

def flickr_open(method, photo_id)
  cache_dir = "#{@cache_path}/flickr"
  Dir::mkdir(cache_dir) unless File::directory?(cache_dir)

  file = "#{cache_dir}/#{photo_id}.#{method}"
  unless File.exist?(file)
    req = Flickr::Request.new(@conf['flickr.apikey'])
    req['method'] = method
    req['photo_id'] = photo_id
    begin
      timeout(5) do
        open(file, 'w') {|fout|
          req.open.each {|line| fout.puts line }
        }
      end
    rescue TimeoutError => e
      File.delete(file)
      raise e
    end
  end
  open(file) {|f| yield f }
end

FLICKER_FORM_PID = 'plugin_flickr_pid'
add_edit_proc do |date|
  photo_id = @cgi.params[FLICKER_FORM_PID][0] or next

  # this code was from image.rb
  case @conf.style.sub( /^blog/i, '' )
  when /^wiki|markdown$/i
    ptag1 = "{{"
    ptag2 = "}}"
  when /^rd$/i
    ptag1 = "((%"
    ptag2 = "%))"
  else
    ptag1 = "&lt;%="
    ptag2 = "%&gt;"
  end

  ptag = %Q|#{ptag1}flickr #{photo_id}#{ptag2}|
  photo = flickr_photo_info(photo_id.to_s, 'thumbnail')
  flickr_image = %Q|<img title="#{photo[:title]}" alt="#{photo[:title]}" src="#{photo[:src]}">|

  <<-FORM
  <h3 class="subtitle">Flickr</h3>
  <input type="hidden" name="#{FLICKER_FORM_PID}" value="#{photo_id}">
  <div class="field title">
    #{flickr_image}
    <input type="button" onclick="flickr_edit_insert(&quot;#{ptag}&quot;)" value="#{@flickr_label_form_add}">
  </div>
  <script type="text/javascript">
  <!--
  function flickr_edit_insert(photo_id) {
    window.document.forms[0].body.value += photo_id;
  }
  //-->
  </script>
  FORM
end

def flickr_slideshow(tag, id = nil)
  id ||= @conf['flickr.id']
  return unless id
  %Q|<iframe align="center" src="http://www.flickr.com/slideShow/index.gne?user_id=#{id}&tags=#{tag}" frameBorder="0" width="500" scrolling="no" height="500"></iframe>|
end

module Flickr
  class Request < Hash
    def initialize(api_key, secret = nil)
      self['api_key'] = api_key
      @secret = secret
    end

    def open(*param, &block)
      Kernel::open(query, *param, &block)
    end

    def query
      sign = @secret ? "&api_sig=#{signature}" : ''
      base_url + sort.map{|key, val| "#{key}=#{val}" }.join('&') + sign
    end

    def signature
      data = sort.map{|key, val| "#{key}#{val}" }.join
      Digest::MD5.hexdigest("#{@secret}#{data}")
    end

    def base_url
      'http://flickr.com/services/rest/?'
    end
  end

  class RequestAuth < Request
    def base_url
      'http://flickr.com/services/auth/?'
    end
  end
end
