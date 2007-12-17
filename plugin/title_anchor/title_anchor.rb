#
# title_anchor.rb:
#
# Copyright (C) 2007 by SHIBATA Hiroshi <h-sbt@nifty.com>
# Distributed under GPL2.
#

def title_anchor
	r = ''
	if /^latest$/ =~ @mode
		r << %Q|<h1>#{h @conf.html_title}</h1>|
	else
		r << %Q|<h1><a href="#{h @conf.index}">#{h @conf.html_title}</a></h1>|
	end
	r
end
