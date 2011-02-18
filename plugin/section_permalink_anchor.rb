# -*- coding: utf-8 -*-
# Copyright (C) 2011, KADO Masanori <kdmsnr@gmail.com>
# You can redistribute it and/or modify it under GPL.
#
# section_permalink_anchor.rb
# - enables section permalink with mod_rewrite
# - depends on section_permalink.rb
#
# sample .htaccess:
# <IfModule mod_rewrite.c>
#    RewriteEngine on
#    RewriteRule ^([0-9\-]+)p?([0-9]*)\.html$ ?date=$1&p=$2 [L]
# </IfModule>

def anchor( s )
	if /^([\-\d]+)#?([pct]\d*)?$/ =~ s then
		if $2 then
			s1 = $1
			s2 = $2
			if $2 =~ /^p/
				"#{s1}#{s2}.html"
			else
				"#{s1}.html##{s2}"
			end
		else
			"#$1.html"
		end
	else
		""
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
