#
# Google Analytics plugin for tDiary
#
# Copyright (C) 2005 TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#
if /^(latest|day|month|nyear)$/ =~ @mode then
	add_footer_proc do
		google_analytics_insert_code
	end
end

def google_analytics_insert_code
	return '' unless @conf['google_analytics.profile']
	<<-HTML
	<script type="text/javascript">
	var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.") ;
	document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E")) ;
	</script>
	<script type="text/javascript">
	var pageTracker = _gat._getTracker("UA-#{h @conf['google_analytics.profile']}");
	pageTracker._initData();
	pageTracker._trackPageview();
	</script>
	HTML
end

# UA-53836-1
add_conf_proc( 'google_analytics', 'Google Analytics' ) do
	if @mode == 'saveconf' then
		@conf['google_analytics.profile'] = @cgi.params['google_analytics.profile'][0]
	end
	<<-HTML
		<h3>Google Analytics Profile</h3>
		<p>set your Profile ID (NNNNN-N)</p>
		<p><input name="google_analytics.profile" value="#{h @conf['google_analytics.profile']}"></p>
	HTML
end
