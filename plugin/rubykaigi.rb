#
# rubykaigi2008.rb: make badge of RubyKaigi2008.
#
# usage: <%= rubykaigi2008 'role' %>
#    role: attendee (default), speaker, sponsor, staff
#
# Copyright (C) TADA Tadashi <sho@spc.gr.jp>
# Distributed under GPL.
#

def rubykaigi2008( role = 'attendee' )
	img = case role
	when 'speaker'
		1
	when 'sponsor'
		2
	when 'staff'
		3
	else
		role = 'attendee'
		0
	end
	%Q|<div style="text-align: center; margin-top: 0.5em; margin-bottom: 0.5em;"><a href="http://jp.rubyist.net/RubyKaigi2008/"><img src="http://rubykaigi.tdiary.net/images/20080617_#{img}.png" width="160" height="79" alt="RubyKaigi2008#{h role.capitalize}" style="border-width: 0px;"></a></div>|
end


def rubykaigi2009( role = 'attendee' )
	%Q|<div style="text-align: center; margin-top: 0.5em; margin-bottom: 0.5em;"><a href="http://rubykaigi.org/2009/"><img src="http://rubykaigi.org/images/goodies/badges/#{role}.gif" width="160" height="160" alt="RubyKaigi2009#{h role.capitalize}" style="border-width: 0px;"></a></div>|
end
