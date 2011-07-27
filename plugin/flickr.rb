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
require 'net/http'
require 'digest/md5'
require 'rexml/document'

@conf['flickr.apikey'] ||= 'f7e7fb8cc34e52db3e5af5e1727d0c0b'
@conf['flickr.default_size'] ||= 'medium'

if /\A(form|edit|preview|showcomment)\z/ === @mode then
	enable_js('flickr.js')
	add_js_setting('$tDiary.plugin.flickr')
	add_js_setting('$tDiary.plugin.flickr.apiKey', %Q|'#{@conf['flickr.apikey']}'|)
	add_js_setting('$tDiary.plugin.flickr.userId', %Q|'#{@conf['flickr.user_id']}'|)
end

def flickr(photo_id, size = nil, place = 'flickr')
  if @conf['flickr.apikey'] == nil || @conf['flickr.apikey'].empty?
    return '[ERROR] flickr.rb: API Key is not specified.'
  end
  size ||= @conf['flickr.default_size']
  size = 'small' if @conf.iphone?
  photo = flickr_photo_info(photo_id.to_s, size)
  unless photo
    return '[ERROR] flickr.rb: failed to get photo.'
  end

  if @cgi.mobile_agent?
    body = %Q|<a href="#{photo[:src]}" class="flickr">#{photo[:title]}</a>|
  else
    body = %Q|<a href="#{photo[:page]}" class="flickr"><img title="#{photo[:title]}" alt="#{photo[:title]}" src="#{photo[:src]}" class="#{place}"|
   unless @conf.iphone?
    body << %Q| width="#{photo[:width]}"| if photo[:width]
    body << %Q| height="#{photo[:height]}"| if photo[:height]
   end
    body << %Q|></a>|
  end

  body
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
          fout.puts req.open
        }
      end
    rescue TimeoutError => e
      File.delete(file)
      raise e
    end
  end
  open(file) {|f| yield f }
end

# delete cache files
def flickr_clear_cache
  cache_dir = "#{@cache_path}/flickr"
  Dir.glob("#{cache_dir}/*.flickr.photos.{getInfo,getSizes}") do |cache|
    # File.unlink(cache)
    File.rename(cache, "#{cache}.org")
  end
end

FLICKER_FORM_PID = 'plugin_flickr_pid'
add_edit_proc do |date|
  <<-FORM
  <div id="flickr_form" style="margin: 1em 0">
    <div>
      Flickr: <input type="text" id="flickr_search_text">
      <select id="flickr_search_count">
        <option value="10">10</option>
        <option value="20">20</option>
        <option value="30">30</option>
        <option value="40">40</option>
        <option value="50">50</option>
      </select>
		件
      <input id="flickr_search" type="button" value="Get flickr photos"></input>
    </div>
    <div id="flickr_photo_size">
	   Photo size:
      <input type="radio" id="flickr_photo_size_square" name="flickr_photo_size" value="square">
      <label for="flickr_photo_size_square">square</label>
      <input type="radio" id="flickr_photo_size_thumbnail" name="flickr_photo_size" value="thumbnail">
      <label for="flickr_photo_size_thumbnail">thumbnail</label>
      <input type="radio" id="flickr_photo_size_small" name="flickr_photo_size" value="small">
      <label for="flickr_photo_size_small">small</label>
      <input type="radio" id="flickr_photo_size_medium" name="flickr_photo_size" value="medium" checked="true">
      <label for="flickr_photo_size_medium">medium</label>
      <input type="radio" id="flickr_photo_size_medium640" name="flickr_photo_size" value="medium 640">
      <label for="flickr_photo_size_medium640">medium 640</label>
      <input type="radio" id="flickr_photo_size_large" name="flickr_photo_size" value="large">
      <label for="flickr_photo_size_large">large</label>
    </div>
    <div id="flickr_photos" style="margin: 1em">
      <!-- <img src="dummy" height="100" width="100" title="dummy"> -->
    </div>
  </div>
  FORM
end

def flickr_slideshow(tag, id = nil)
  id ||= @conf['flickr.id']
  return unless id
  %Q|<iframe align="center" src="http://www.flickr.com/slideShow/index.gne?user_id=#{id}&amp;tags=#{tag}" frameBorder="0" width="500" scrolling="no" height="500"></iframe>|
end

def flickr_slideshow_by_set(set_id)
  return unless set_id
  %Q|<iframe align="center" src="http://www.flickr.com/slideShow/index.gne?set_id=#{set_id}" frameBorder="0" width="500" scrolling="no" height="500"></iframe>|
end

module Flickr
  class Request < Hash
    def initialize(api_key, secret = nil)
      self['api_key'] = api_key
      @secret = secret
    end

    def open
      Net::HTTP.version_1_2
      Net::HTTP.start('www.flickr.com') {|http|
        response = http.get(query)
        response.body
      }
    end

    def query
      sign = @secret ? "&api_sig=#{signature}" : ''
      base_path + sort.map{|key, val| "#{key}=#{val}" }.join('&') + sign
    end

    def signature
      data = sort.map{|key, val| "#{key}#{val}" }.join
      Digest::MD5.hexdigest("#{@secret}#{data}")
    end

    def base_path
      '/services/rest/?'
    end
  end

  class RequestAuth < Request
    def base_path
      '/services/auth/?'
    end
  end
end
