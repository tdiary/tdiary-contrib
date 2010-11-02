# -*- coding: utf-8 -*-
# category_similar.rb:
#   * shows similar posts under the diary
#   * depends on plugin/category.rb
# You can redistribute it and/or modify it under the same license as tDiary.

def category_similar(categories, max_item)
	info = Category::Info.new(@cgi, @years, @conf)
	months = [['01', '02', '03'], ['04', '05', '06'], ['07', '08', '09'], ['10', '11', '12']][@date.strftime("%m").to_i / (3 + 1)] # quarter
	years = { @date.strftime("%Y") => months }
	hash = @category_cache.categorize(info.category, years)
	items = []
	hash.values_at(*categories).inject({}){|r, i|
		r.merge i if !r.nil? and !i.nil?
	}.to_a.each do |ymd_ary|
		ymd = ymd_ary[0]
		ary = ymd_ary[1]
		next if ymd == @date.strftime('%Y%m%d')
		t = Time.local(ymd[0,4], ymd[4,2], ymd[6,2]).strftime(@conf.date_format)
		ary.each do |idx, title, excerpt|
			items << %Q|<a href="#{h @index}#{anchor "#{ymd}#p#{'%02d' % idx}"}" title="#{h excerpt}">#{t}#p#{'%02d' % idx}</a> #{apply_plugin(title)}|
		end
	end
	
	unless items.empty?
		'<div class="section">' +
		"<h3 class='category-similar'>#{category_similar_label}</h3>" +
		"<ul>" +
		items.sort.reverse[0, max_item].map{|i| "<li>#{i}</i>" }.join("\n") +
		"</ul>" +
		"</div>"
	end
end

add_conf_proc('category_similar', category_similar_label, 'basic') do
	if @mode == 'saveconf'
		@conf["category_similar.excludes"] =
			@cgi.params["category_similar.excludes"][0]
		@conf["category_similar.section_amounts"] =
			@cgi.params["category_similar.section_amounts"][0].to_i
	end

	<<-HTML
<h3 class="subtitle">#{category_similar_label}</h3>
<h4>#{category_similar_excludes}</h4>
<textarea name="category_similar.excludes" rows="5" cols="50">#{h @conf['category_similar.excludes']}</textarea>

<h4>#{category_similar_amounts}</h4>
<input type="text" name="category_similar.section_amounts" value="#{h @conf['category_similar.section_amounts']}" style="text-align:right;"/>
HTML
end

add_body_leave_proc do |date, idx|
	diary = @diaries[date.strftime('%Y%m%d')]
	if @mode =~ /day/ and diary.categorizable?
		categories = []
		diary.each_section do |s|
			categories += s.categories unless s.categories.empty?
		end
		categories.delete_if do |i|
			@conf['category_similar.excludes'].split(/\r?\n/).include? i
		end
		category_similar(categories, @conf['category_similar.section_amounts'])
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
