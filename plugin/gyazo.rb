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
	size = 512
	oembed = JSON.parse(Net::HTTP.get(URI("https://api.gyazo.com/api/oembed?url=#{permalink_url}")), symbolize_names: true)
	p oembed
	width = oembed[:width]
	height = oembed[:height]
	if width > height
		height = size * height / width
		width = size
	else
		width = size * width / height
		height = size
	end
	url = oembed[:url].gsub(%r|/thumb/\d+/|, "/thumb/#{size}/")
	%Q[<img src="#{url}" class="#{style}" width=#{width} height=#{height} alt="#{alt}" title="#{alt}">]
end

def gyazo_right(permalink_url, alt = '[description]')
	gyazo(permalink_url, alt, 'right')
end

def gyazo_left(permalink_url, alt = '[description]')
	gyazo(permalink_url, alt, 'left')
end

def gyazo_list
	endpoint = "https://api.gyazo.com/api/images"
	access_token = "52d5d581cf2a8f37a33bd5df9e1b0132f9fb171db305c1d07263c664cf732dc4"
	per_page = 5
	uri = "#{endpoint}?access_token=#{access_token};per_page=#{per_page}"
	JSON.parse(Net::HTTP.get(URI(uri)), symbolize_names: true).map{|i|
		[i[:permalink_url], i[:thumb_url]]
	}.delete_if{|is|
		is[1].empty?
	}
end

add_form_proc do |date|
	'<div class="form"><div class="caption">Gyazo</div><div class="gyazo-images">' +
	gyazo_list.map{|i|
		%Q[<img src="#{i[1]}" data-url="#{i[0]}"> ]
	}.join +
	'</div></div>'
end