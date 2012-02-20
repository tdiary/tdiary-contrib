# -*- coding: utf-8 -*-
#
# select_style.rb: a plugin for selecting styles
# Distributed under the GPL
#
# [CAUTION] You need to insert a line to tdiary.conf after "load_cgi_conf"
#    @style = @options2['style'] if @options2['style']
#

# styles
def saveconf_style
	if @mode == 'saveconf' then
		@conf['style'] = @cgi.params['style'][0]
	end
end

if @mode =~ /^(conf|saveconf)$/ then
	@conf_style_list = []
	Dir::glob( "#{::TDiary::PATH}/tdiary/{style/,}*_style.rb" ) do |style_file|
		style = File::basename( style_file ).sub( /_style\.rb$/, '' )
		@conf_style_list << style
	end
end

add_conf_proc( 'style', 'スタイル' ) do
	saveconf_style

	r = <<-HTML
	<h3 class="subtitle">スタイルの指定</h3>
	#{"<p>スタイル (日記の文法) を指定します。</p>" unless @conf.mobile_agent?}
	<p>
	<select name="style">
	HTML
	@conf_style_list.each do |style|
		r << %Q|<option value="#{style}"#{if (style == @conf['style']) or (!@conf['style'] && style == 'tdiary') then " selected" end}>#{style}</option>|
	end
	r << <<-HTML
	</select>
	</p>
	#{"<p>スタイルについての詳細は<a href=\"http://tdiary-users.sourceforge.jp/cgi-bin/wiki.cgi?%A5%B9%A5%BF%A5%A4%A5%EB\">スタイル - tDiary の記法</a>をごらんください。</p>" unless @conf.mobile_agent?}
	HTML
end
