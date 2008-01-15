# category_to_tag.rb - show categories list in end of each section
# $Revision: 1.6 $
#
# Copyright (C) 2005, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#

if respond_to?( :categorized_title_of_day ) then # BlogKit
	def categorized_title_of_day( date, title )
		@category_to_tag_list = {}
		cats, stripped = title.scan( /^((?:\[[^\]]+\])+)\s*(.*)/ )[0]
		if cats then
			cats.scan( /\[([^\]]+)\]+/ ).flatten.each do |tag|
				@category_to_tag_list[tag] = true # true when blog
			end
		else
			stripped = title
		end
		stripped
	end
	add_body_leave_proc do |date|
		category_to_tag_list
	end
elsif respond_to?( :category_anchor ) # diary
	add_section_enter_proc do |date, index|
		@category_to_tag_list = {}
	end
	alias subtitle_link_original subtitle_link
	def subtitle_link( date, index, subtitle )
		s = ''
		if subtitle then
			s = subtitle.sub( /^(\[([^\[]+?)\])+/ ) do
				$&.scan( /\[(.*?)\]/ ) do |tag|
					@category_to_tag_list[tag] = false # false when diary
				end
				''
			end
		end
		subtitle_link_original( date, index, s.strip )
	end
	add_section_leave_proc do |date, index|
		category_to_tag_list
	end
end

def category_to_tag_list
	if @category_to_tag_list and not @category_to_tag_list.empty? then
		r = '<div class="tags">Tags: '
		@category_to_tag_list.each do |tag, blog|
			if blog
				r << %Q|<a href="#{h @index}?blogcategory=#{h tag}">#{tag}</a> |
			else
				r << category_anchor( "#{tag}" ).sub( /^\[/, '' ).sub( /\]$/, '' ) << ' '
			end
		end
		r << "</div>\n"
	end
end

