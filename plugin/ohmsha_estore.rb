# -*- coding: utf-8 -*-
# You can redistribute it and/or modify it under the same license as tDiary.
#
# display book info in https://estore.ohmsha.co.jp/ like amazon.rb
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

require 'open-uri'
require 'json'
def ohmsha_estore( id, doc = nil )
	if !@conf.secure and !(result = ohmsha_estore_cache_get(id)).nil?
		return result
	end

	html = ''
	begin
		open("https://estore.ohmsha.co.jp/titles/#{id}"){|r|html = r.read}
	rescue SecurityError # avoid error on unlink
	end
	info = JSON.parse(html.scan(%r|<script type='application/ld\+json'>(.*?)</script>|m).flatten[0])

	result = <<-EOS
	<a class="amazon-detail" href="#{h link}"><span class="amazon-detail">
		<img class="amazon-detail left" src="#{h info['image']}"
		height="150" width="100"
		alt="#{h info['name']}">
		<span class="amazon-detail-desc">
			<span class="amazon-title">#{h info['name']}</span><br>
			<span class="amazon-label">#{h info['description'].split.first}</span><br>
			<span class="amazon-price">#{h info['offers']['price'].to_f.to_i}円</span>
		</span><br style="clear: left">
	</span></a>
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
