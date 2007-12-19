# ja/account_ad.rb $Revision: 1.2 $
#
# Japanese resources for account_ad.rb
#
# Copyright (c) 2005 Hiroshi SHIBATA <h-sbt@nifty.com>
# Distributed under the GPL
#

if @mode == 'conf' || @mode == 'saveconf'
   add_conf_proc( 'account_ad', 'Account Auto-Discovery' ) do
      saveconf_account_ad
      account_ad_init
      <<-HTML
      <h3 class="subtitle">Account Name</h3>
      <p><input name="account.name" value="#{h(@conf['account.name'])}" size="8" /></p>
      <h3 class="subtitle">Account Service</h3>
      <p><input name="account.service" value="#{h(@conf['account.service'])}" size="40" /></p>
      HTML
   end
end
