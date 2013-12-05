# -*- coding: utf-8 -*-
# You can redistribute it and/or modify it under the same license as tDiary.
#
# display book info in http://estore.ohmsha.co.jp/ like amazon.rb
# USAGE: {{ohmsha_estore '978427406694P'}}

def ohmsha_estore_cache_dir
	cache = "#{@cache_path}/ohmsha-estore"
	Dir.mkdir( cache ) unless File.directory?( cache )
	cache
end

def ohmsha_estore_cache_set( id, result )
	File.open( "#{ohmsha_estore_cache_dir}/#{id}", "w" ) do |f|
		f.write result
	end
end

def ohmsha_estore_cache_get( id )
	File.open( "#{ohmsha_estore_cache_dir}/#{id}", "r" ) do |f|
		f.read
	end
rescue
	nil
end

def ohmsha_estore( id, doc = nil )
	if !@conf.secure and !(result = ohmsha_estore_cache_get(id)).nil?
		return result
	end

	domain = "http://estore.ohmsha.co.jp"
	image = "#{domain}/images/covers/#{id}.gif"
	link = "#{domain}/titles/#{id}"
	require 'open-uri'
	doc ||= open(link, &:read).gsub(%r|</?fb:.*?>|, '')
	require 'rexml/document'
	xml = REXML::Document.new( doc )
	biblio = "//html/body/div/div[2]/div/div/div/div[2]"
	title = REXML::XPath.match( xml,
		"#{biblio}/h2").first.text
	author = REXML::XPath.match( xml,
		"#{biblio}/div" ).first.text

	description =
		REXML::XPath.match( xml, '//html/body/div/div[2]/div/div/div[2]' ).
		first.text

	result = <<-EOS
	<a class="amazon-detail" href="#{h link}"><div class="amazon-detail">
		<img class="amazon-detail left" src="#{h image}"
		height="150" width="100"
		alt="#{h title}">
		<div class="amazon-detail-desc">
			<span class="amazon-title">#{h title}</span><br>
			<span class="amazon-author">#{h author}</span><br>
			<span class="amazon-label">#{h description}</span><br>
		</div><br style="clear: left">
	</div></a>
EOS

	ohmsha_estore_cache_set( id, result ) unless @conf.secure
	result
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
