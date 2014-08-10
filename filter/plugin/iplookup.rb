# iplookup.rb
#
# Copyright (c) 2005 SHIBATA Hiroshi <h-sbt@nifty.com>
# Distributed under the GPL
#
if TDIARY_VERSION >= '2.1.2.20050825' then
   add_conf_proc( 'iplookup', @iplookup_label, 'security' ) do
      iplookup_conf_proc
   end
else
   add_conf_proc( 'iplookup', @iplookup_label ) do
      iplookup_conf_proc
   end
end
def iplookup_conf_proc
	if @mode == 'saveconf' then
      if @cgi.params['iplookup.ip.list'] && @cgi.params['iplookup.ip.list'][0]
         @conf['iplookup.ip.list'] = @cgi.params['iplookup.ip.list'][0]
      else
         @conf['iplookup.ip.list'] = nil
      end

      if @cgi.params['iplookup.safe_ip.list'] && @cgi.params['iplookup.safe_ip.list'][0]
         @conf['iplookup.safe_ip.list'] = @cgi.params['iplookup.safe_ip.list'][0]
      else
         @conf['iplookup.safe_ip.list'] = nil
      end

	end

   # initialize DNSBL list
   @conf['iplookup.ip.list'] = "bsb.spamlookup.net\nopm.blitzed.org\nniku.2ch.net" unless @conf['iplookup.ip.list']

	result = <<-HTML
		<h3>#{@iplookup_ip_label}</h3>
		<p>#{@iplookup_ip_label_desc}</p>
		<p><textarea name="iplookup.ip.list" cols="70" rows="5">#{CGI::escapeHTML( @conf['iplookup.ip.list'] )}</textarea></p>
	HTML
end
