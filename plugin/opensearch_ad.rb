# opensearch_ad.rb $Revision: 1.1 $
#
# Copyright (c) 2008 SHIBATA Hiroshi <h-sbt@nifty.com>
# Distributed under the GPL
#

if /^(latest|day)$/ =~ @mode then
	if @conf['opensearch.xml'] and @conf['opensearch.title'] then
		opensearch_xml = @conf['opensearch.xml']
		opensearch_title = @conf['opensearch.title']
		
		add_header_proc do	
			result = <<-HTML
			<link type="application/opensearchdescription+xml" rel="search" title="#{h(opensearch_title)}" href="#{h(opensearch_xml)}">
   	   HTML
			result.gsub( /^\t\t/, '' )
		end
	end
end

add_conf_proc( 'opensearch_ad', 'OpenSearch Auto-Discovery' ) do
	if @mode == 'saveconf'
		@conf['opensearch.xml'] = @cgi.params['opensearch.xml'][0]
		@conf['opensearch.title'] = @cgi.params['opensearch.title'][0]
	end

	<<-HTML
	<h3 class="subtitle">Tilte for OpenSearch</h3>
	<p><input name="opensearch.title" value="#{h(@conf['opensearch.title'])}" size="80" /></p>
 	<h3 class="subtitle">URI for OpenSearch description XML</h3>
 	<p><input name="opensearch.xml" value="#{h(@conf['opensearch.xml'])}" size="80" /></p>
 	HTML
end
