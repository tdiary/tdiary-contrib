# hb_footer4sec_js.rb $Revision 1.0 $
#
# Copyright (c) 2008 SHIBATA Hiroshi <h-sbt@nifty.com>
# You can redistribute it and/or modify it under GPL2.
#

def permalink( date, index, escape = true )
	ymd = date.strftime( "%Y%m%d" )
	uri = @conf.index.dup
	uri.sub!( %r|\A(?!https?://)|i, @conf.base_url )
	uri.gsub!( %r|/\.(?=/)|, "" ) # /././ -> /
	link = uri + anchor( "#{ymd}p%02d" % index )
	link.sub!( "#", "%23" ) if escape
	link
end

add_section_leave_proc do |date, index|
	if @mode == 'day' and not bot?
		<<-SCRIPT
		<script type= "text/javascript"><!--
		var hatena_bookmark_anywhere_limit = 10;
		var hatena_bookmark_anywhere_style = true;
		var hatena_bookmark_anywhere_collapse = true;
		var hatena_bookmark_anywhere_url = "#{permalink(date, index)}";
		//--></script>
		<script src="#{@conf.base_url}hatena-bookmark-anywhere.js" type="text/javascript" charset="utf-8"></script>
		<div id="hatena_bookmark_anywhere"></div>
		SCRIPT
	end
end
