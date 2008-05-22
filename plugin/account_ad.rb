# account_ad.rb $Revision: 1.3 $
#
# Copyright (c) 2008 SHIBATA  Hiroshi <h-sbt@nifty.com>
# Distributed under the GPL
#

if /^(latest|day)$/ =~ @mode then
	
	@account_ad_list = {
		# Service => ServiceHomepage
		'Hatena' => 'http://www.hatena.ne.jp/',
	}
	
	if @conf['account.service'] and @conf['account.name'] then
		if @mode == "day" and not @date == nil then
			permalink=@conf.base_url + anchor( @date.strftime('%Y%m%d') )
		else
			permalink=@conf.base_url
		end
		
		account_service = @account_ad_list[@conf['account.service']]
		account_name = @conf['account.name']
		
		add_header_proc do	
			result = <<-HTML
			<!--
			<rdf:RDF
			   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			   xmlns:foaf="http://xmlns.com/foaf/0.1/">
			<rdf:Description rdf:about="#{permalink}">
			   <foaf:maker rdf:parseType="Resource">
			     <foaf:holdsAccount>
			       <foaf:OnlineAccount foaf:accountName="#{h account_name}">
			         <foaf:accountServiceHomepage rdf:resource="#{h account_service}" />
			       </foaf:OnlineAccount>
			     </foaf:holdsAccount>
			   </foaf:maker>
			</rdf:Description>
			</rdf:RDF>
			-->
   	   HTML
			result.gsub( /^\t\t/, '' )
		end
	end
end

add_conf_proc( 'account_ad', 'Account Auto-Discovery' ) do

	if @mode == 'saveconf' then
      @conf['account.name'] = @cgi.params['account.name'][0]
      @conf['account.service'] = @cgi.params['account.service'][0]
	end

	options = ''
	@account_ad_list.each_key do |key|
		options << %Q|<option value="#{h key}"#{" selected" if @conf['account.service'] == key}>#{h key}</option>\n|
	end
		
	<<-HTML
   <h3 class="subtitle">Account Service</h3>
	<p><select name="account.service">
		#{options}
	</select></p>
   <h3 class="subtitle">Account Name</h3>
   <p><input name="account.name" value="#{h @conf['account.name']}" /></p>
   HTML
end
