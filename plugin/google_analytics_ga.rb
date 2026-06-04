#
# Google Analytics GA4 plugin for tDiary
#
# Copyright (C) 2025 KITADAI Yukinori <algebraicallyClosedField@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#
if /^(?:latest|day|month|nyear|search)$/ =~ @mode then
	add_footer_proc do
		google_analytics_ga_insert_code
	end
end

def google_analytics_ga_insert_code
	return '' unless @conf['google_analytics_ga.profile']
	<<-HTML
		<!-- Global site tag (gtag.js) - Google Analytics -->
		<script async src="https://www.googletagmanager.com/gtag/js?id=#{@conf['google_analytics_ga.profile']}"></script>
		<script>
			window.dataLayer = window.dataLayer || [];
			function gtag(){dataLayer.push(arguments);}
			gtag('js', new Date());

			gtag('config', '#{@conf['google_analytics_ga.profile']}');
		</script>
	HTML
end

# G-XXXXXXXXXX
add_conf_proc( 'google_analytics_ga', 'Google Analytics GA4' ) do
	if @mode == 'saveconf' then
		@conf['google_analytics_ga.profile'] = @cgi.params['google_analytics_ga.profile'][0]
	end
	r = <<-HTML
		<h3>Google Analytics GA4 Profile</h3>
		<p>set your Profile ID (G-XXXXXXXXXX)</p>
		<p><input name="google_analytics_ga.profile" value="#{h @conf['google_analytics_ga.profile']}"></p>
	HTML
	r
end

if defined? AMP
	add_amp_header_proc do
		%Q|<script async custom-element="amp-analytics"
			src="https://cdn.ampproject.org/v0/amp-analytics-0.1.js"></script>|
	end

	add_amp_body_enter_proc do
		profile_id = %w(google_analytics_ga.profile).map {|key|
			@conf[key]
		}.find {|profile|
			profile && !profile.empty?
		}
		<<-HTML
			<amp-analytics type="gtag" data-credentials="include">
			<script type="application/json">
			{
				"vars": {
				 	"gtag_id": "#{h profile_id}"
				 	"config" : {
						"#{h profile_id}": { "groups": "default" }
					}
				}
			}
			</script>
			</amp-analytics>
		HTML
	end
end
