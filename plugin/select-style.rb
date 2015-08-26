#
# select-style.rb: select a style from installed styles
#
# add a line below, after load_cgi_conf in tdiary.conf:
#    @style = @options2['style'] if @options2 && @options2['style']
#

def saveconf_style
	if @mode == 'saveconf' then
		@conf['style'] = @cgi.params['style'][0]
	end
end

def enum_styles
	TDiary::Style.constants(false).grep(/Diary$/).delete_if{|s|
		s =~ /Base|Categorizable|Uncategorizable/
	}.map{|s|
		s.to_s.sub(/Diary$/, '').downcase
	}.each{|s|
		yield s
	}
end

add_conf_proc( 'style', 'スタイル', 'update' ) do
	saveconf_style

	labels = {
		'tdiary' => 'tDiary',
		'wiki' => 'Wiki',
		'gfm' => 'GFM',
		'etdiary' => 'etDiary',
		'emptdiary' => 'emptDiary',
		'rd' => 'RD',
	}

	r = <<-HTML
		<h3 class="subtitle">スタイルの指定</h3>
		<p>スタイル (日記の文法) を指定します。</p>
		<p>
		<select name="style">
	HTML
	enum_styles do |style|
		label = labels[style] || style
		select = if (label == @conf['style']) or (!@conf['style'] && style == 'tdiary')
			' selected'
		else
			''
		end
		r << %Q|<option value="#{label}"#{select}>#{labels[style] || style}</option>|
	end
	r << <<-HTML
	</select>
	</p>
	<p>スタイルについての詳細は<a href="http://tdiary-users.sourceforge.jp/cgi-bin/wiki.cgi?%A5%B9%A5%BF%A5%A4%A5%EB">スタイル - tDiary の記法</a>をごらんください。</p>
	HTML
end
