# hb_footer4sec_js.rb $Revision 1.0 $
#
# Copyright (c) 2008 SHIBATA Hiroshi <h-sbt@nifty.com>
# You can redistribute it and/or modify it under GPL2.
#

def permalink( date, index )
	ymd = date.strftime( "%Y%m%d" )
	uri = @conf.index.dup
	uri[0, 0] = @conf.base_url unless %r|^https?://|i =~ uri
	uri.gsub!( %r|/\./|, '/' )

	uri + anchor( "#{ymd}p%02d" % index )
end

add_section_leave_proc do |date, index|
	if @mode == 'day' and not bot? and not @conf.mobile_agent? then
		<<-SCRIPT
		<script type= "text/javascript">/*<![CDATA[*/
		var hatena_bookmark_anywhere_limit = 10;
		var hatena_bookmark_anywhere_style = true;
		var hatena_bookmark_anywhere_collapse = true;
		var hatena_bookmark_anywhere_url = "#{permalink(date, index)}";
		/*]]>*/</script>
		<script src="#{@conf.base_url}hatena-bookmark-anywhere.js" type="text/javascript" charset="utf-8"></script>
		<div id="hatena_bookmark_anywhere"></div>
		SCRIPT
	end
end
