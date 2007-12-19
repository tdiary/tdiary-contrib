# ja/opensearch_ad.rb $Revision: 1.1 $
#
# Japanese resources for opensearch_ad.rb
#
# Copyright (c) 2006 Hiroshi SHIBATA <h-sbt@nifty.com>
# Distributed under the GPL
#

if @mode == 'conf' || @mode == 'saveconf'
   add_conf_proc( 'opensearch_ad', 'OpenSearch Auto-Discovery' ) do

      saveconf_opensearch_ad
      opensearch_ad_init

      <<-HTML
      <h3 class="subtitle">Tilte for OpenSearch</h3>
      <p><input name="opensearch.title" value="#{h(@conf['opensearch.title'])}" size="80" /></p>
      <h3 class="subtitle">URI for OpenSearch description XML</h3>
      <p><input name="opensearch.xml" value="#{h(@conf['opensearch.xml'])}" size="80" /></p>
      HTML
   end
end
