#
# slideshow.rb : tDiary plugin for show slides
#
# Copyright (C) 2016 TADA Tadashi
# Distributed under the GPL2 or any later version.
#
# @options['slideshow.css'] = "URL of CSS"
#

enable_js('slideshow.js')

def slideshow
	%Q|<button class="slideshow">Start Slideshow &gt;&gt;</button>|
end

if @conf['slideshow.css']
	add_header_proc do
		%Q[<link rel="stylesheet" href="#{h @conf['slideshow.css']}" media="screen">]
	end
end
