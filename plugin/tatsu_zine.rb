# -*- coding: utf-8 -*-
# Copyright (C) 2011, KADO Masanori <kdmsnr@gmail.com>
# You can redistribute it and/or modify it under GPL.
#
# display book info in http://tatsu-zine.com/ like amazon.rb
# USAGE: {{tatsu_zine 1}}

def tatsu_zine_cache_dir
	cache = "#{@cache_path}/tatsu-zine"
	Dir.mkdir( cache ) unless File.directory?( cache )
	cache
end

def tatsu_zine_cache_set( id, result )
	File.open( "#{tatsu_zine_cache_dir}/#{id}", "w" ) do |f|
		f.write result
	end
end

def tatsu_zine_cache_get( id )
	File.open( "#{tatsu_zine_cache_dir}/#{id}", "r" ) do |f|
		f.read
	end
rescue
	nil
end

def tatsu_zine( id, doc = nil )
	if !@conf.secure and !(result = tatsu_zine_cache_get(id)).nil?
		return result
	end

	domain = "http://tatsu-zine.com"
	link = "#{domain}/books/#{id}"
	require 'open-uri'
	doc ||= open(link)

	require 'rexml/document'
	xml = REXML::Document.new( doc )
	section = "//html/body/div/div[3]/section/div[2]"
	title = REXML::XPath.match( xml, "#{section}/h1" ).first.text
	author = REXML::XPath.match( xml, "#{section}/p[@class='author']" ).first.text
	description =
		REXML::XPath.match( xml, "#{section}/div[@class='description']" ).
		first.to_s.gsub(/<\/?[^>]*>/, "").gsub(/β版/, '')
	image = domain +
		REXML::XPath.match( xml, "/html/body/div/div[3]/section/div/img").
		first.attributes["src"]

	result = <<-EOS
	<a class="amazon-detail" href="#{h link}"><div class="amazon-detail">
		<img class="amazon-detail left" src="#{h image}"
		height="150" width="100"
		alt="#{h title}">
		<span class="amazon-detail-desc">
			<span class="amazon-title">#{h title}</span><br>
			<span class="amazon-author">#{h author}</span><br>
			<span class="amazon-label">#{h description}</span><br>
		</span><br style="clear: left">
	</div></a>
EOS

	tatsu_zine_cache_set( id, result ) unless @conf.secure
	result
rescue
	link
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
