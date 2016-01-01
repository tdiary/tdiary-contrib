#
# rubykaigi.rb: make badges of RubyKaigi.
#
# usage: <%= rubykaigi 'role', 'size' %>
#	  role: attendee (default), speaker, sponsor, staff, committer, individual sponsor, away
#	  size: large(160x160), small(160x90)
#
# Copyright (C) TADA Tadashi <t@tdtds.jp>
# Distributed under GPL.
#

def rubykaigi2015( role = 'attendee', size = nil )
	r = role.split(/[ _]+/).join('-')
	s = "-@#{h size}" unless size.nil? || size == "1x"
	%Q|<a href="http://rubykaigi.org/2015/" style="display:block;margin:8px auto;text-align:center;"><img src="http://rubykaigi.org/2015/images/goodies/banner-160-#{h r}#{s}.png" alt="RubyKaigi 2015 #{h r}"></a>|
end

def rubykaigi2014( role = 'attendee', size = nil )
	r = role.split(/[ _]+/).join('-')
	s = "@#{h size}" unless size.nil?
	%Q|<a href="http://rubykaigi.org/2014/" style="display:block;margin:8px auto;text-align:center;"><img src="http://rubykaigi.org/2014/images/badge-for-#{h r}#{s}.png" alt="RubyKaigi 2014 #{h r}"></a>|
end

def rubykaigi2013( role = 'attendee', size = nil )
	r = role.split(/[ _]+/).map{|s| s.capitalize}.join
	s = "@#{h size}" unless size.nil?
	%Q|<a href="http://rubykaigi.org/2013/" style="display:block;margin:8px auto;text-align:center;"><img src="http://rubykaigi.org/2013/images/badge#{h r}#{s}.png" alt="RubyKaigi 2013 #{h r}"></a>|
end

def sappororubykaigi2012( role = 'attendee' )
	r = role.split(/[ _]+/).map{|s| s.capitalize}.join
	%Q|<a href="http://sapporo.rubykaigi.org/2012/" style="display:block;margin:8px auto;text-align:center;"><img src="http://sapporo.rubykaigi.org/2012/images/goodiesBadge160#{h r}.png" alt="SapporoRubyKaigi 2012 #{h r}"></a>|
end

def kansairubykaigi04( role = 'attendee' )
	badges = {
		'attendee' => "attendee_taiyou",
		'speaker' => "speaker_shika",
		'staff' => "staff_daibutsu"
	}

	%Q|<a href="http://regional.rubykaigi.org/kansai04" style="display:block;margin:8px auto;text-align:center;"><img src="http://regional.rubykaigi.org/images/kansai04/#{badges[role]}.png" alt="KansaiRubyKaigi04 #{h role.capitalize}"></a>|
end

def rubykaigi2011( role = 'attendee', size = 'large' )
	badges = Hash::new( 'attendee' ).update({
		'committer' => 'committer',
		'individual sponsor' => 'individualSponsor',
		'sponsor' => 'sponsor',
		'staff' => 'staff',
		'speaker' => 'speaker',
		'attendee' => 'attendee',
		'away' => 'attendeeAway'
	})

	width, height = size == 'large' ? ['160','160'] : ['160', '90']

	%Q|<a href="http://rubykaigi.org/2011/" style="display:block;margin:8px auto;text-align:center;"><img src="http://rubykaigi.org/2011/goodies/badges/#{width}x#{height}#{badges[role]}.png" width="#{width}" height="#{height}" alt="RubyKaigi2010 #{h role.capitalize}" style="border-width: 0px;"></a>|
end

alias :rubykaigi :rubykaigi2015

#----- OLD EDITIONS -----#

def sappororubykaigi03( role = 'attendee' )
	%Q|<a href="http://regional.rubykaigi.org/sapporo03/" style="display:block;margin:8px auto;text-align:center;"><img src="http://regional.rubykaigi.org/images/sapporo03/badge_#{h role}.gif" alt="badge_#{h role}.gif"></a>|
end

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

def rubykaigi2009( role = 'attendee' )
	%Q|<div style="text-align: center; margin-top: 0.5em; margin-bottom: 0.5em;"><a href="http://rubykaigi.org/2009/"><img src="http://rubykaigi.org/2009/images/goodies/badges/#{h role}.gif" width="160" height="160" alt="RubyKaigi2009#{h role.capitalize}" style="border-width: 0px;"></a></div>|
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
	%Q|<div style="text-align: center; margin-top: 0.5em; margin-bottom: 0.5em;"><a href="http://jp.rubyist.net/RubyKaigi2008/"><img src="http://userimages.tdiary.net/rubykaigi/20080617_#{img}.png" width="160" height="79" alt="RubyKaigi2008#{h role.capitalize}" style="border-width: 0px;"></a></div>|
end

def sappororubykaigi02( role = 'attendee' )
	%Q|<div style="text-align: center; margin-top: 0.5em; margin-bottom: 0.5em;"><a href="http://regional.rubykaigi.org/sapporo02/"><img src="http://ruby-sapporo.org/sappororubykaigi02/#{h role}.gif" width="160" height="90" alt="SapporoRubyKaigi02#{h role.capitalize}" style="border-width: 0px;"></a></div>|
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
