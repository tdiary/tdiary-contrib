#
# monthly_autopagerize.rb - tDiary plugin
#
# add <link rel="prev"> and <link rel="next"> tags for AutoPagerize at monthly mode
#
# Copyright (C) 2009 MATSUI Shinsuke <poppen@karashi.org>
# You can redistribute it and/or modify it under GPL2.
#

if /^month$/ =~ @mode then
	add_header_proc do
		stream = @conf['monthly_autopagerize.stream'] || 0
		result = String.new

		ym = []
		@years.keys.each do |y|
			ym += @years[y].collect {|m| y + m}
		end
		ym.sort!
		now = @date.strftime( '%Y%m' )
		return '' unless ym.index( now )
		prev_month = ym.index( now ) == 0 ? nil : ym[ym.index( now )-1]
		next_month = ym[ym.index( now )+1]

		case stream
		when 0
			rel_prev_month = 'next'
			rel_next_month = 'prev'
		when 1
			rel_prev_month = 'prev'
			rel_next_month = 'next'
		else
			rel_prev_month = 'next'
			rel_next_month = 'prev'
		end

		if prev_month then
			result << %Q[<link rel="#{rel_prev_month}" title="#{h navi_prev_month}" href="#{h @index}#{anchor( prev_month )}">\n\t]
		end
		if next_month then
			result << %Q[<link rel="#{rel_next_month}" title="#{h navi_next_month}" href="#{h @index}#{anchor( next_month )}">\n\t]
		end

		result.chop.chop
	end
end

add_conf_proc( 'monthly_autopagerize', 'Monthly AutoPagerize' ) do
	if @mode == 'saveconf' then
		@conf['monthly_autopagerize.stream'] = @cgi.params['monthly_autopagerize.stream'][0].to_i
	end
	<<-HTML
		<h3>Stream of Monthly AutoPagerize</h3>
		<p><select name="monthly_autopagerize.stream">
			<option value="0"#{" selected" if @conf['monthly_autopagerize.stream'] == 0}>To Past</option>
			<option value="1"#{" selected" if @conf['monthly_autopagerize.stream'] == 1}>To Future</option>
		</select></p>
	HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vi: ts=3 sw=3
