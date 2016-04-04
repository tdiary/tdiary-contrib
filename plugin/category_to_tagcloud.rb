#
# category_to_tagcloud.rb
#
# Usage:
# <% tag_list n %>
# n: 表示最大数(default: nil)
#
# options configurable through settings:
#   @options['tagcloud.hidecss'] : cssの出力 default: false
#
# This plugin modifes and includes tagcloud-ruby.
# http://yatsu.info/articles/2005/08/05/ruby%E3%81%A7tagcloud-tagcloud-ruby

require 'pstore'

def category_enable?
	!@plugin_files.grep(/\/category\-legacy\.rb$/).empty?
end

def add tag, url, count, elapsed_time
	@counts[tag] = count
	@urls[tag] = url
	@elapsed_times[tag] = elapsed_time
end

def print_html
	tags = @counts.sort_by {|a, b| b }.reverse.map {|a, b| a }
	return '' if tags.empty?
	tags = tags[0..@limit-1] if @limit

	if tags.size == 1
		tag = tags[0]
		url = @urls[tag]
		elapsed_time = @elapsed_times[tag]
		return %{<ul class="tagcloud"><li class="tagcloud24#{elapsed_time}"><a title="#{tag}" href="#{url}">#{tag}</a></li></ul>\n}
	end

	min = Math.sqrt(@counts[tags.last])
	max = Math.sqrt(@counts[tags.first])
	factor = 0

	# special case all tags having the same count
	if max - min == 0
		min = min - 24
		factor = 1
	else
	  factor = 24 / (max - min)
	end

	html = %{<ul class="tagcloud">}
	tags.sort{|a,b| a.downcase <=> b.downcase}.each do |tag|
		count = @counts[tag]
		level = ((Math.sqrt(count) - min) * factor).to_i
		html << %{<li class="tagcloud#{level}#{@elapsed_times[tag]}"><a title="#{tag} - #{count}" href="#{@urls[tag]}">#{tag}</a></li>\n}
	end
	html << "</ul>"
	html
end

def init_category_to_tagcloud
	@counts = Hash.new
	@urls = Hash.new
	@elapsed_times = Hash.new
	@conf['category_to_tagcloud.cache'] ||= "#{@cache_path}/category2tagcloud.cache"
	@limit = nil
end

def tag_list limit = nil
	return '' if bot?
	return '' unless category_enable?

	begin
		init_category_to_tagcloud
		cache = @conf['category_to_tagcloud.cache']
		@limit = limit

		PStore.new(cache).transaction(read_only=true) do |db|
			break unless db.root?('tagcloud') or db.root?('last_update')
			break if Time.now.strftime('%Y%m%d').to_i > db['last_update']
			@counts = db['tagcloud'][0]
			@urls = db['tagcloud'][1]
			@elapsed_times = db['tagcloud'][2]
		end

		gen_tag_list if @urls.empty?
		print_html
	rescue TypeError
		'<p class="message">category plugin does not support category_to_tagcloud plugin. use category_legacy plugin instead of categoty plugin.</p>'
	end
end

def styleclass diff
	c = ' old'
	if diff > 30
		c = " oldest"
	elsif diff > 14
		c = " older"
	elsif diff < 7
		c = " hot"
	end
	c
end

def gen_tag_list
	init_category_to_tagcloud if @mode == 'append' or @mode == 'replace'
	cache = @conf['category_to_tagcloud.cache']
	info = Category::Tagcloud_Info.new(@cgi, @years, @conf)
	categorized = @category_cache.categorize(info.category, info.years)

	categorized.keys.each do |key|
		count = categorized[key].size
		ymd = categorized[key].keys.sort.reverse
		diff = (Time.now - Time.local(ymd[0][0,4], ymd[0][4,2], ymd[0][6,2])) / 86400
		url = "#{@conf.index}?category=#{CGI.escape(key)}"
		add(key, url, count, "#{styleclass(diff.to_i)}")
	end

	PStore.new(cache).transaction do |db|
		db['last_update'] = Time.now.strftime('%Y%m%d').to_i
		db['tagcloud'] = [@counts, @urls, @elapsed_times]
	end
end

def tagcloud_css
	r = ''
	r = "\t<style type=\"text/css\"><!--\n"
	for level in 0..24
		font = 12 + level
		r << "\t.tagcloud li.tagcloud#{level} {font-size: #{font}px;}\n"
	end

	r << "\t.tagcloud {line-height:1}\n"
	r << "\t.tagcloud ul {list-style-type:none;}\n"
	r << "\t.tagcloud li {display:inline;}\n"
	r << "\t.tagcloud li a {text-decoration:none;}\n"
	r << "\t--></style>\n"
	r
end

add_update_proc do
	gen_tag_list if @mode == 'append' or @mode == 'replace'
end

add_header_proc do
	tagcloud_css unless @conf['tagcloud.hidecss']
end


if category_enable?
	module Category
		class Tagcloud_Info < Info
			def years
				now_year = Time.now.year
				now_month = Time.now.month
				r = Hash.new

				months = [
					['01'],['01','02'],['01','02','03'],['02','03','04'],['03','04','05'],
					['04','05','06'],['05','06','07'],['06','07','08'],['07','08','09'],
					['08','09','10'],['09','10','11'],['10','11','12']
				][now_month - 1]

				r[now_year.to_s] = months
				case now_month
				when 1
					r["#{now_year - 1}"] = ['11','12']
				when 2
					r["#{now_year - 1}"] = ['12']
				end
				r
			end
		end
	end
end

## vim: ts=3
