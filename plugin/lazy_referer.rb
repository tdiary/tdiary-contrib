# -*- coding: utf-8; -*-
#
# lazy_referer.rb: lazy loading referer
#
# Copyright (C) 2013 by MATSUOKA Kohei <kmachu@gmail.com>
# You can distribute it under GPL.
#
if /^(day|form|edit)$/ =~ @mode and not bot? then
	enable_js('referer.js')

	#
	# overwrite method: draw only referer area (content will feach with ajax)
	#
	def referer_of_today_long( diary, limit )
		return if limit == 0
		return unless diary
		date = diary.date.strftime('%Y%m%d')
		# FIXME: endpoint is should created by TDiary::Plugin, because easy customize routing
		endpoint = "#{@conf.index}?plugin=referer&date=#{date}"
		%Q[<button class="lazy_referer" style="padding: 0.5em; width: 20em;" data-endpoint="#{h endpoint}">#{referer_today}</button>\n]
	end
end

#
# return referer of date as is (html)
#
add_content_proc('referer') do |date|
	diary = @diaries[date]
	referer_load_current( diary )
	referer_of_today_long( diary, 100 )
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
