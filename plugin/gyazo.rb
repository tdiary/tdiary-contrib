#
# gyazo.rb: gyazo plugin for tDiary
#
# SPDX-License-Identifier: GPL-2.0-or-later
#
require 'net/http'
require 'json'
require 'fileutils'

if /^(form|edit|formplugin|showcomment)$/ =~ @mode then
	enable_js('gyazo.js')
end

def gyazo_extract_id(permalink_url)
	# Extract Gyazo ID from permalink URL
	# e.g., "https://gyazo.com/71a4efdd066f5c2ebd11ee5a37b8f9ef" -> "71a4efdd066f5c2ebd11ee5a37b8f9ef"
	permalink_url.to_s.strip.match(%r{gyazo\.com/([a-f0-9]+)}i)&.captures&.first
end

def gyazo_oembed_fetch(permalink_url)
	gyazo_id = gyazo_extract_id(permalink_url)
	return nil unless gyazo_id

	cache_dir = File.join(@cache_path, 'gyazo')
	cache_file = File.join(cache_dir, "#{gyazo_id}.json")

	# Load from cache if available (skip cache in preview mode)
	if @mode != 'preview' && File.exist?(cache_file)
		begin
			json_data = File.read(cache_file)
			return JSON.parse(json_data, symbolize_names: true)
		rescue => e
			@logger.warn("gyazo.rb: cache read error for #{gyazo_id}: #{e.message}")
			# Continue to fetch from API if cache read fails
		end
	end

	# Fetch from Gyazo OEmbed API
	begin
		json_data = Net::HTTP.get(URI("https://api.gyazo.com/api/oembed?url=#{permalink_url}"))
		oembed = JSON.parse(json_data, symbolize_names: true)

		# Save to cache
		FileUtils.mkdir_p(cache_dir) unless File.directory?(cache_dir)
		File.write(cache_file, json_data)

		oembed
	rescue => e
		@logger.error("gyazo.rb: API error for #{permalink_url}: #{e.message}")
		nil
	end
end

def gyazo(permalink_url, alt = '[description]', style = 'photo')
	size = @conf['gyazo_max_size'] || 512

	oembed = gyazo_oembed_fetch(permalink_url)
	return '' unless oembed

	url = oembed[:url].gsub(%r|/thumb/\d+/|, "/thumb/#{size}/")
	width = oembed[:width].to_i
	height = oembed[:height].to_i
	if width > 0 && height > 0
		if width > height
			height = size * height / width
			width = size
		else
			width = size * width / height
			height = size
		end
		%Q[<img src="#{url}" class="#{style}" width=#{width} height=#{height} alt="#{alt}" title="#{alt}">]
	else # no size informations in API
		%Q[<img src="#{url}" class="#{style}" width=#{size} alt="#{alt}" title="#{alt}">]
	end
end

def gyazo_right(permalink_url, alt = '[description]')
	gyazo(permalink_url, alt, 'right')
end

def gyazo_left(permalink_url, alt = '[description]')
	gyazo(permalink_url, alt, 'left')
end

def gyazo_list
	endpoint = "https://api.gyazo.com/api/images"
	access_token = @conf['gyazo_token']
	return [] if access_token == nil || access_token.empty?
	per_page = @conf['gyazo_max_images'] || 5
	uri = "#{endpoint}?access_token=#{access_token};per_page=#{per_page}"
	begin
		JSON.parse(Net::HTTP.get(URI(uri)), symbolize_names: true).map{|i|
			[i[:permalink_url], i[:thumb_url]]
		}.delete_if{|is|
			is[1].empty?
		}
	rescue => e
		@logger.error(e)
		return []
	end
end

add_form_proc() do |date|
	'<div class="form"><div class="caption">Gyazo</div><div class="gyazo-images">' +
	gyazo_list.map{|i|
		%Q[<img src="#{i[1]}" data-url="#{i[0]}"> ]
	}.join +
	'</div></div>'
end

def gyazo_clear_cache
	cache_dir = File.join(@cache_path, 'gyazo')
	return unless File.directory?(cache_dir)

	count = 0
	Dir.glob(File.join(cache_dir, '*.json')).each do |cache_file|
		File.delete(cache_file)
		count += 1
	end
	@logger.info("gyazo.rb: cleared #{count} cache files")
	count
end

add_conf_proc('gyazo', 'Gyazo') do
	if @mode == 'saveconf'
		@conf['gyazo_token'] = @cgi.params['gyazo_token'][0]
		@conf['gyazo_max_images'] = @cgi.params['gyazo_max_images'][0].to_i
		@conf['gyazo_max_size'] = @cgi.params['gyazo_max_size'][0].to_i

		if @cgi.params['gyazo_clear_cache'][0] == 'true'
			count = gyazo_clear_cache
			@conf.save
		end
	end
	@conf['gyazo_max_images'] = 5 if @conf['gyazo_max_images'].to_i < 1
	@conf['gyazo_max_size'] = 512 if @conf['gyazo_max_size'].to_i < 1

	r = ''
	r << %Q|<h3 class="subtitle">Gyazo API Access Token</h3>|
	r << %Q|<p>Get your token from <a href="https://gyazo.com/oauth/applications">Gyazo Applications</a></p>|
	r << %Q|<p><input name="gyazo_token" value="#{h @conf['gyazo_token']}" size=64></p>|
	r << %Q|<h3 class="subtitle">Max images in list</h3>|
	r << %Q|<p><input name="gyazo_max_images" value="#{h @conf['gyazo_max_images']}" size=3></p>|
	r << %Q|<h3 class="subtitle">Max image size</h3>|
	r << %Q|<p><input name="gyazo_max_size" value="#{h @conf['gyazo_max_size']}" size=4> px</p>|
	r << %Q|<h3 class="subtitle">Clear cache</h3>|
	r << %Q|<p><label for="gyazo_clear_cache">|
	r << %Q|<input type="checkbox" id="gyazo_clear_cache" name="gyazo_clear_cache" value="true">|
	r << %Q| Clear all cached OEmbed data</label></p>|
	r
end