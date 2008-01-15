#
# openid.rb: Insert OpenID delegation information. $Revision: 1.10 $
#
# Copyright (C) 2005, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#

if /^(latest|conf|saveconf)$/ =~ @mode then
	@openid_list = {
		# service => [openid.server, openid.delegate(replace #ID# as account name), X-XRDS-Location(replace #ID# as account name)]
		'Hatena' => ['https://www.hatena.ne.jp/openid/server', 'http://www.hatena.ne.jp/#ID#/', nil],
		'livedoor' => ['http://auth.livedoor.com/openid/server', 'http://profile.livedoor.com/#ID#', nil],
		'LiveJournal' => ['http://www.livejournal.com/openid/server.bml', 'http://#ID#.livejournal.com/', nil],
		'OpenID.ne.jp' => ['http://www.openid.ne.jp/user/auth', 'http://#ID#.openid.ne.jp', 'http://#ID#.openid.ne.jp/user/xrds'],
		'TypeKey' => ['http://www.typekey.com/t/openid/', 'http://profile.typekey.com/#ID#/', nil],
		'Videntiry.org' => ['http://videntity.org/serverlogin?action=openid', 'http://#ID#.videntity.org/', nil],
		'Vox' => ['http://www.vox.com/services/openid/server', 'http://#ID#.vox.com/', nil],
		'myopenid.com' => ['http://www.myopenid.com/server', 'http://#ID#.myopenid.com', "http://www.myopenid.com/xrds?username=#ID#"],
	}

	if @conf['openid.service'] and @conf['openid.id'] then
		add_header_proc do
			result = <<-HTML
			<link rel="openid.server" href="#{h @openid_list[@conf['openid.service']][0]}">
			<link rel="openid.delegate" href="#{h @openid_list[@conf['openid.service']][1].sub( /#ID#/, @conf['openid.id'] )}">
			HTML
			result << <<-HTML if @openid_list[@conf['openid.service']][2]
			<meta http-equiv="X-XRDS-Location" content="#{h @openid_list[@conf['openid.service']][2].sub( /#ID#/, @conf['openid.id'] )}">
			HTML
			result.gsub( /^\t\t/, '' )
		end
	end
end

add_conf_proc( 'openid', @openid_conf_label ) do
	if @mode == 'saveconf' then
		@conf['openid.service'] = @cgi.params['openid.service'][0]
		@conf['openid.id'] = @cgi.params['openid.id'][0]
	end

	options = ''
	@openid_list.each_key do |key|
		options << %Q|<option value="#{h key}"#{" selected" if @conf['openid.service'] == key}>#{h key}</option>\n|
	end
	<<-HTML
	<h3 class="subtitle">#{@openid_service_label}</h3>
	<p>#{@openid_service_desc}</p>
	<p><select name="openid.service">
		#{options}
	</select></p>

	<h3 class="subtitle">#{@openid_id_label}</h3>
	<p>#{@openid_id_desc}</p>
	<p><input name="openid.id" value="#{h @conf['openid.id']}"></p>
	HTML
end
