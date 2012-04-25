#
# description_from_body.rb - set meta description by first section's body in day mode
#
# Copyright (C) 2011, TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL.
#

alias description_tag_dfb_orig description_tag
def description_tag
	if @mode == 'day' then
		diary = @diaries[@date.strftime '%Y%m%d']
		return '' unless diary

		body = ''
		diary.each_section do |sec|
			body = remove_tag( apply_plugin( sec.body_to_html ) ).strip
			break
		end
		%Q|<meta name="description" content="#{@conf.shorten body, 256}">|
	else
		description_tag_dfb_orig
	end
end
