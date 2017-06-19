# -*- coding: utf-8 -*-
# Copyright (C) 2013, TADA Tadashi <t@tdtds.jp>
# Original code from tatsu_zine.rb by KADO Masanori <kdmsnr@gmail.com>
# You can redistribute it and/or modify it under GPL.
#
# display book info in http://p.booklog.jp/ like amazon.rb
# USAGE: {{puboo 9999}}

require 'open-uri'

def puboo_cache_dir
	cache = "#{@cache_path}/puboo"
	Dir.mkdir( cache ) unless File.directory?( cache )
	cache
end

def puboo_cache_set( id, result )
	File.open( "#{puboo_cache_dir}/#{id}", "w" ) do |f|
		f.write result
	end
end

def puboo_cache_get( id )
	File.open( "#{puboo_cache_dir}/#{id}", "r" ) do |f|
		f.read
	end
rescue
	nil
end

def puboo( id, doc = nil )
	if !@conf.secure and !(result = puboo_cache_get(id)).nil?
		return result
	end

	link = "http://p.booklog.jp/book/#{id}"
	doc ||= open( link ).read.force_encoding('UTF-8')
	title = doc.match(%r|<meta property="og:title"\s*content="(.*)"|).to_a[1]
	image = doc.match(%r|<meta property="og:image"\s*content="(.*)"|).to_a[1]
	price = doc.match(%r|<th class="th_2">価格</th>.*?<span>(.*?)</span>.*?<br />|m).to_a[1]
	author = doc.match(%r|<th>作者</th>(.*?)</td>|m).to_a[1].gsub(/<.*?>/, '').strip

	result = <<-EOS
	<a class="amazon-detail" href="#{h link}"><span class="amazon-detail">
		<img class="amazon-detail left" src="#{h image}"
		height="150" width="100"
		alt="#{h title}">
		<span class="amazon-detail-desc">
			<span class="amazon-title">#{h title}</span><br>
			<span class="amazon-author">#{h author}</span><br>
			<span class="amazon-price">#{h price}</span>
		</span><br style="clear: left">
	</span></a>
EOS

	puboo_cache_set( id, result ) unless @conf.secure
	result
rescue 
	link
end

if __FILE__ == $0
	require 'test/unit'
	class TestTatsuZine < Test::Unit::TestCase
		def setup
			@conf = Struct.new("Conf", :secure).new(true)
			def h(str); str; end
		end

		def test_puboo
			expect = <<-EOS
	<a class="amazon-detail" href="http://p.booklog.jp/book/70667"><span class="amazon-detail">
		<img class="amazon-detail left" src="http://img.booklog.jp/667BDD9E-B13E-11E2-82F3-6425FFDA975F_l.jpg"
		height="150" width="100"
		alt="入門Puppet - Automate Your Infrastructure">
		<span class="amazon-detail-desc">
			<span class="amazon-title">入門Puppet - Automate Your Infrastructure</span><br>
			<span class="amazon-author">栗林健太郎</span><br>
			<span class="amazon-price">890円（税込）</span>
		</span><br style="clear: left">
	</span></a>
EOS
			assert_equal expect, puboo('70667')
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
