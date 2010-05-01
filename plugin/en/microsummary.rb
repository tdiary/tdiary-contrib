# ja/microsummary.rb
#
# Japanese resources for microsummary.rb
#
# Copyright (c) 2006 elytsllams <smallstyle@gmail.com>
# Distributed under the GPL
#

if @mode == 'conf' || @mode == 'saveconf'
   add_conf_proc( 'microsummary', 'Microsummary Generator' ) do
      saveconf_microsummary
      microsummary_init
      <<-HTML
      <h3 class="subtitle">URI for microsummary generator XML</h3>
      <p><input name="generator.xml" value="#{CGI::escapeHTML(@conf['generator.xml'])}" size="60"></p>
      HTML
   end
end
