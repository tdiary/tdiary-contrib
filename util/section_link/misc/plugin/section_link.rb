# Copyright (C) 2011, KADO Masanori <kdmsnr@gmail.com>
# You can redistribute it and/or modify it under GPL.
#
# section_link.rb
# - enables section link and shows section title
# - depends on:
#   - tdiary/tdiary_day_ext.rb
#   - tdiary/tdiaryext_style.rb
#   - tdiary/wikiext_style.rb

alias :_orig_subtitle_link :subtitle_link
def subtitle_link( date, index, subtitle )
	if @cgi.params['section'].join('') != ''
		index = @cgi.params['section'][0]
	end
	r = _orig_subtitle_link( date, index, subtitle )
	r.gsub(/#p(\d+)/){"&section=#{$1}"}
end

alias :_orig_title_tag :title_tag
def title_tag
	if @cgi.params['section'].join('') != '' and
			@mode == 'day' and diary = @diaries[@date.strftime('%Y%m%d')]
		sec = []
		diary.each_section do |s|
			sec << s
		end
		site_title = " - #{_orig_title_tag.gsub( /<.*?>/, '')}"
		title = sec[@cgi.params['section'][0].to_i - 1].stripped_subtitle_to_html
		return "<title>#{apply_plugin(title, true).gsub(/[\r\n]/, '')}#{h site_title }</title>"

	else
		_orig_title_tag
	end
end

if @cgi.params["section"].join('') != ""
	add_section_leave_proc do
		diary = @diaries[@date.strftime("%Y%m%d")]

		i = 1
		sections = []
		diary.each_section do |s|
			unless i == @cgi.params["section"][0].to_i
				sections << [i, s]
			end
			i += 1
		end

		unless sections.empty?
			"<hr>\n<ol>\n" +
			sections.map{|i, s|
				[i, my(@date.strftime("%Y%m%d") + "p" + sprintf("%02d", i),
					apply_plugin(s.stripped_subtitle_to_html, true))]
			}.map{|i, s|
				"<li value='#{i}'>#{s}</li>"
			}.join("\n") + "\n</ol>\n"
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
