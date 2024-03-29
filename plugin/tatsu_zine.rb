# -*- coding: utf-8 -*-
# Copyright (C) 2011, KADO Masanori <kdmsnr@gmail.com>
# You can redistribute it and/or modify it under GPL.
#
# display book info in http://tatsu-zine.com/ like amazon.rb
# USAGE: {{tatsu_zine 1}}

require 'open-uri'
require 'openssl'

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

	link = "https://tatsu-zine.com/books/#{id}"
	doc ||= URI.open(link, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
	title = doc.match(%r|<meta property="og:title" content="(.*)">|).to_a[1]
	image = doc.match(%r|<meta property="og:image" content="(.*)">|).to_a[1]
	price = doc.match(%r|span itemprop="price">(.*?)</span>|m).to_a[1].gsub(/,/,'').to_i
	author = doc.match(%r|<p itemprop="author" class="author">(.*)</p>|).to_a[1]

	result = <<-EOS
	<a class="amazon-detail" href="#{h link}"><span class="amazon-detail">
		<img class="amazon-detail left" src="#{h image}"
		height="150" width="100"
		alt="#{h title}">
		<span class="amazon-detail-desc">
			<span class="amazon-title">#{h title}</span><br>
			<span class="amazon-author">#{h author}</span><br>
			<span class="amazon-price">#{h price}円</span>
		</span><br style="clear: left">
	</span></a>
EOS

	tatsu_zine_cache_set( id, result ) unless @conf.secure
	result
rescue => e
	@logger.error(e)
	link
end

if __FILE__ == $0
	require 'test/unit'
	class TestTatsuZine < Test::Unit::TestCase
		def setup
			@conf = Struct.new("Conf", :secure).new(true)
			def h(str); str; end
		end

		def test_tatsu_zine
			expect = <<-EOS
	<a class="amazon-detail" href="http://tatsu-zine.com/books/winrubybuild"><span class="amazon-detail">
		<img class="amazon-detail left" src="http://tatsu-zine.com/images/books/1/cover_l.jpg"
		height="150" width="100"
		alt="Ruby環境構築講座 Windows編">
		<span class="amazon-detail-desc">
			<span class="amazon-title">Ruby環境構築講座 Windows編</span><br>
			<span class="amazon-author">arton</span><br>
			<span class="amazon-price">1036</span>
		</span><br style="clear: left">
	</span></a>
EOS
			assert_equal expect, tatsu_zine('winrubybuild')
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
