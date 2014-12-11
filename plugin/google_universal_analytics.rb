#
# Google Universal Analytics plugin for tDiary
#
# Copyright (C) 2014 TSUNEMATSU Shinya <s@tnmt.info>
# You can redistribute it and/or modify it under GPL2.
#
if /^(?:latest|day|month|nyear|search)$/ =~ @mode then
	add_footer_proc do
		google_universal_analytics_insert_code
	end
end

def google_universal_analytics_insert_code
	return '' unless @conf['google_universal_analytics.profile']
	<<-HTML
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-#{h @conf['google_universal_analytics.profile']}', 'auto');
  ga('require', 'displayfeatures');
  ga('send', 'pageview');
</script>
	HTML
end

# UA-53836-1
add_conf_proc( 'google_universal_analytics', 'Google Universal Analytics' ) do
	if @mode == 'saveconf' then
		@conf['google_universal_analytics.profile'] = @cgi.params['google_universal_analytics.profile'][0]
	end
	<<-HTML
		<h3>Google Universal Analytics Profile</h3>
		<p>set your Profile ID (NNNNN-N)</p>
		<p><input name="google_universal_analytics.profile" value="#{h @conf['google_universal_analytics.profile']}"></p>
	HTML
end
