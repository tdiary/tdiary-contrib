#
# rubykaigi.rb: make badges of RubyKaigi.
#
# usage: <%= rubykaigi 'role' %>
#    role: attendee (default), speaker, sponsor, staff, committer, individual sponsor
#
# Copyright (C) TADA Tadashi <t@tdtds.jp>
# Distributed under GPL.
#

def rubykaigi2010( role = 'attendee' )
	badges = Hash::new( 'attendee' ).update({
		'committer' => 'committer',
		'individual sponsor' => 'individual_sponsor',
		'sponsor' => 'sponsor',
		'staff' => 'staff',
		'speaker' => 'speaker',
		'attendee' => 'attendee',
		'away' => 'away'
	})
	%Q|<a href="http://rubykaigi.org/2010/" style="display:block;margin:8px auto;text-align:center;"><img src="http://rubykaigi.org/2010/badge/#{badges[role]}.png" width="160" height="201" alt="RubyKaigi2010 #{h role.capitalize}" style="border-width: 0px;"></a>|
end

alias :rubykaigi :rubykaigi2010

#----- OLD EDITIONS -----#

def rubykaigi2009( role = 'attendee' )
	%Q|<div style="text-align: center; margin-top: 0.5em; margin-bottom: 0.5em;"><a href="http://rubykaigi.org/2009/"><img src="http://rubykaigi.org/2009/images/goodies/badges/#{role}.gif" width="160" height="160" alt="RubyKaigi2009#{h role.capitalize}" style="border-width: 0px;"></a></div>|
end

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

def sappororubykaigi02( role = 'attendee' )
	%Q|<div style="text-align: center; margin-top: 0.5em; margin-bottom: 0.5em;"><a href="http://regional.rubykaigi.org/sapporo02/"><img src="http://ruby-sapporo.org/sappororubykaigi02/#{role}.gif" width="160" height="90" alt="SapporoRubyKaigi02#{h role.capitalize}" style="border-width: 0px;"></a></div>|
end
