#
# Google Analytics plugin for tDiary
#
# Copyright (C) 2005 TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#
add_footer_proc do
	google_analytics_insert_code
end

def google_analytics_insert_code
	return '' unless @conf['google_analytics.profile']
	<<-HTML
	<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
	</script>
	<script type="text/javascript">
	_uacct = "UA-#{h @conf['google_analytics.profile']}";
	urchinTracker();
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
