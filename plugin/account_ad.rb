# account_ad.rb $Revision: 1.3 $
#
# Copyright (c) 2005 SHIBATA  Hiroshi <h-sbt@nifty.com>
# Distributed under the GPL
#

add_header_proc do
   account_ad_init

   account_name = @conf['account.name']
   account_service = @conf['account.service']

   if @mode == "day"
      permalink=@conf.base_url+anchor(@date.strftime('%Y%m%d'))
   else
      permalink=@conf.base_url
   end

	if account_name.length > 0 then
   	<<-HTML
			<!--
			<rdf:RDF
			   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			   xmlns:foaf="http://xmlns.com/foaf/0.1/">
			<rdf:Description rdf:about="#{permalink}">
			   <foaf:maker rdf:parseType="Resource">
			     <foaf:holdsAccount>
			       <foaf:OnlineAccount foaf:accountName="#{h(account_name)}">
			         <foaf:accountServiceHomepage rdf:resource="#{h(account_service)}" />
			       </foaf:OnlineAccount>
			     </foaf:holdsAccount>
			   </foaf:maker>
			</rdf:Description>
			</rdf:RDF>
			-->
   	HTML
	else
		''
	end
end

def account_ad_init
   @conf['account.name'] ||= ""
   @conf['account.service'] ||= "http://www.hatena.ne.jp/"
end

if @mode == 'saveconf'
   def saveconf_account_ad
      @conf['account.name'] = @cgi.params['account.name'][0]
      @conf['account.service'] = @cgi.params['account.service'][0]
   end
end
