# -*- coding: utf-8 -*-
# Copyright (C) 2011, KADO Masanori <kdmsnr@gmail.com>
# You can redistribute it and/or modify it under GPL.
#
# section_permalink.rb
# - enables section permalink and shows section title

def section_mode?
	@mode == 'day' and @cgi.params['p'][0].to_s != ""
end

# Change permalink
def anchor( s )
	if /^([\-\d]+)#?([pct]\d*)?$/ =~ s then
		if $2 then
			s1 = $1
			s2 = $2
			if $2 =~ /^p/
				"?date=#{s1}&p=#{s2.gsub(/p/, '')}"
			else
				"?date=#{s1}.html##{s2}"
			end
		else
			"?date=#$1"
		end
	else
		""
	end
end

# Change HTML title to section name
alias :_orig_title_tag :title_tag
def title_tag
	if section_mode? and diary = @diaries[@date.strftime('%Y%m%d')]
		sections = diary.instance_variable_get(:@sections)

		title = "<title>"
		section = sections[@cgi.params['p'][0].to_i - 1].stripped_subtitle_to_html
		title << apply_plugin(section, true).chomp
		title << " - #{h @html_title}"
		title << "(#{@date.strftime( '%Y-%m-%d' )})" if @date
		title << "</title>"
		return title
	else
		_orig_title_tag
	end
rescue
	_orig_title_tag
end

add_header_proc do
	if section_mode? and diary = @diaries[@date.strftime('%Y%m%d')]
		index = @cgi.params['p'][0]
<<-EOS
<script>
$(document).ready(function() {
  var anc = $("a[name=p#{h(index)}]");
  anc.parent().css("background-color", "yellow");
  var dest = anc.offset().top;
  $("body").animate({scrollTop: dest});
});
</script>
EOS
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
