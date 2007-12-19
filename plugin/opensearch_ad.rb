# opensearch_ad.rb $Revision: 1.1 $
#
# Copyright (c) 2006 SHIBATA Hiroshi <h-sbt@nifty.com>
# Distributed under the GPL
#

add_header_proc do
	opensearch_ad_init

	opensearch_xml = @conf['opensearch.xml']
	opensearch_title = @conf['opensearch.title']

	if opensearch_xml.length > 0 then
	<<-HTML
      <link type="application/opensearchdescription+xml" rel="search" title="#{h(opensearch_title)}" href="#{h(opensearch_xml)}">
	HTML
	else
		''
	end

end

def opensearch_ad_init
	@conf['opensearch.xml'] ||= ""
	@conf['opensearch.title'] ||= ""
end

if @mode == 'saveconf'
	def saveconf_opensearch_ad
		@conf['opensearch.xml'] = @cgi.params['opensearch.xml'][0]
		@conf['opensearch.title'] = @cgi.params['opensearch.title'][0]
	end
end

