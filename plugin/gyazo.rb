#
# gyazo.rb: gyazo plugin for tDiary
#
# SPDX-License-Identifier: GPL-2.0-or-later
#
require 'net/http'
require 'json'

if /^(form|edit|formplugin|showcomment)$/ =~ @mode then
	enable_js('gyazo.js')
end

def gyazo(permalink_url, alt = '[description]', style = 'photo')
	size = @conf['gyazo_max_size'] || 512
	oembed = JSON.parse(Net::HTTP.get(URI("https://api.gyazo.com/api/oembed?url=#{permalink_url}")), symbolize_names: true)
	p oembed
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
	JSON.parse(Net::HTTP.get(URI(uri)), symbolize_names: true).map{|i|
		[i[:permalink_url], i[:thumb_url]]
	}.delete_if{|is|
		is[1].empty?
	}
end

add_form_proc() do |date|
	'<div class="form"><div class="caption">Gyazo</div><div class="gyazo-images">' +
	gyazo_list.map{|i|
		%Q[<img src="#{i[1]}" data-url="#{i[0]}"> ]
	}.join +
	'</div></div>'
end

add_conf_proc('gyazo', 'Gyazo') do
	if @mode == 'saveconf'
		@conf['gyazo_token'] = @cgi.params['gyazo_token'][0]
		@conf['gyazo_max_images'] = @cgi.params['gyazo_max_images'][0].to_i
		@conf['gyazo_max_size'] = @cgi.params['gyazo_max_size'][0].to_i
	end
	@conf['gyazo_max_images'] = 5 if @conf['gyazo_max_images'] < 1
	@conf['gyazo_max_size'] = 512 if @conf['gyazo_max_size'] < 1

	r = ''
	r << %Q|<h3 class="subtitle">Gyazo API Access Token</h3>|
	r << %Q|<p>Get your token from <a href="https://gyazo.com/oauth/applications">Gyazo Applications</a></p>|
	r << %Q|<p><input name="gyazo_token" value="#{h @conf['gyazo_token']}" size=64></p>|
	r << %Q|<h3 class="subtitle">Max images in list</h3>|
	r << %Q|<p><input name="gyazo_token" value="#{h @conf['gyazo_max_images']}" size=3></p>|
	r << %Q|<h3 class="subtitle">Max image size</h3>|
	r << %Q|<p><input name="gyazo_token" value="#{h @conf['gyazo_max_size']}" size=4> px</p>|
	r
end