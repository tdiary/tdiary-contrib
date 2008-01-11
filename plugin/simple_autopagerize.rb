#
# simple_autopagerize.rb - tDiary plugin
#
# add <link rel="prev"> and <link rel="next"> tags for AutoPagerize
#
# Copyright (C) 2008 MATSUI Shinsuke <poppen@karashi.org>
# You can redistribute it and/or modify it under GPL2.
#

return unless /^(latest|month)$/ =~ @mode

add_header_proc do
	result = String.new
	case @mode
	when 'latest'
		if @conf['ndays.prev'] then
			result << %Q[<link rel="next" title="#{h navi_prev_ndays}" href="#{h @index}#{anchor( @conf['ndays.prev'] + '-' + @conf.latest_limit.to_s )}">\n\t]
		end
		if @conf['ndays.next'] then
			result << %Q[<link rel="prev" title="#{h navi_next_ndays}" href="#{h @index}#{anchor( @conf['ndays.next'] + '-' + @conf.latest_limit.to_s )}">\n\t]
		end
	when 'month'
		ym = []
		@years.keys.each do |y|
			ym += @years[y].collect {|m| y + m}
		end
		ym.sort!
		now = @date.strftime( '%Y%m' )
		return '' unless ym.index( now )
		prev_month = ym.index( now ) == 0 ? nil : ym[ym.index( now )-1]
		next_month = ym[ym.index( now )+1]

		if prev_month then
			result << %Q[<link rel="prev" title="#{h navi_prev_month}" href="#{h @index}#{anchor( prev_month )}">\n\t]
		end
		if next_month then
			result << %Q[<link rel="next" title="#{h navi_next_month}" href="#{h @index}#{anchor( next_month )}">\n\t]
		end
	end
	result.chop.chop
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vi: ts=3 sw=3
