#
# brow_si.rb: insert brow.si code
#
# Copyright (C) 2012 by hb <smallstyle@gmail.com>
#

add_conf_proc( "brow_si", "Brow.si" ) do
	if @mode == "saveconf"
		@conf["brow.si.site_id"] = @cgi.params["brow.si.site_id"][0]
	end

	<<-HTML
		<h3 class="subtitle">Website Brow.si Site ID</h3>
		<p><input name="brow.si.site_id" value="#{h @conf["brow.si.site_id"]}" size="80"></p>
	HTML
end

add_footer_proc do
	if @conf["brow.si.site_id"] and @conf.smartphone?

		<<-SCRIPT
		<script type="text/javascript">
			window['_brSiteId'] = '#{h @conf["brow.si.site_id"]}';
			(function(d){
				var i='browsi-js'; if (d.getElementById(i)) {return;}
				var js=d.createElement("script"); js.id=i; js.async=true;
				js.src='//js.brow.si/br.js'; (d.head || d.getElementsByTagName('head')[0]).appendChild(js);
			})(document);
		</script>
		SCRIPT
	end
end
