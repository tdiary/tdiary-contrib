#
# openid.rb: Insert OpenID delegation information. $Revision: 1.10 $
#
# Copyright (C) 2005, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#

@openid_config = (Struct.const_defined?("OpenIdConfig") ? Struct::OpenIdConfig :
	Struct.new("OpenIdConfig", :openid, :openid2, :x_xrds_location))

if /^(?:latest|conf|saveconf)$/ =~ @mode then
	@openid_list = {
		# service => @openid_config.new(
		#    [openid.server, openid.delegate(replace <ID> as account name)],   # openid
		#    [openid2.provider, openid2.local_id(replace <ID> as account name)], # openid2
		#    'X-XRDS-Location(replace <ID> as account name)'),
		'Hatena' => @openid_config.new(['https://www.hatena.ne.jp/openid/server', 'http://www.hatena.ne.jp/<ID>/']),
		'livedoor' => @openid_config.new(['http://auth.livedoor.com/openid/server', 'http://profile.livedoor.com/<ID>']),
		'LiveJournal' => @openid_config.new(['http://www.livejournal.com/openid/server.bml', 'http://<ID>.livejournal.com/']),
		'OpenID.ne.jp' => @openid_config.new(
			['http://www.openid.ne.jp/user/auth', 'http://<ID>.openid.ne.jp'],
			nil,
			'http://<ID>.openid.ne.jp/user/xrds'),
		'TypeKey' => @openid_config.new(['http://www.typekey.com/t/openid/', 'http://profile.typekey.com/<ID>/']),
		'Vox' => @openid_config.new(['http://www.vox.com/services/openid/server', 'http://<ID>.vox.com/']),
		'myopenid.com' => @openid_config.new(
			['http://www.myopenid.com/server', 'http://<ID>.myopenid.com'], # openid
			['http://www.myopenid.com/server', 'http://<ID>.myopenid.com'], # openid2
			"http://www.myopenid.com/xrds?username=<ID>"),
		'claimID.com' => @openid_config.new(
			['http://openid.claimid.com/server', 'http://openid.claimid.com/<ID>'],
			nil, #['http://openid.claimid.com/server', 'http://openid.claimid.com/<ID>'],
			'http://claimid.com/<ID>/xrds'),
		'Personal Identity Provider (PIP)' => @openid_config.new(
			['http://pip.verisignlabs.com/server', 'http://<ID>.pip.verisignlabs.com/'],
			['http://pip.verisignlabs.com/server', 'http://<ID>.pip.verisignlabs.com/'],
			'http://pip.verisignlabs.com/user/<ID>/yadisxrds'),
		'Yahoo! Japan' => @openid_config.new(
			nil,
			['https://open.login.yahooapis.jp/openid/op/auth', 'https://me.yahoo.co.jp/a/<ID>'],
			'http://open.login.yahoo.co.jp/openid20/www.yahoo.co.jp/xrds'),
		'Yahoo!' => @openid_config.new(
			nil,
			['https://open.login.yahooapis.com/openid/op/auth', 'https://me.yahoo.com/a/<ID>'],
			'http://open.login.yahooapis.com/openid20/www.yahoo.com/xrds'),
		'Wassr' => @openid_config.new(['https://wassr.jp/open_id/auth', 'https://wassr.jp/user/<ID>']),
	}

	if @conf['openid.service'] and @conf['openid.id'] then
		openid_service = @openid_list[@conf['openid.service']]
		openid_id = @conf['openid.id']
		result = ''
		add_header_proc do
			result = <<-HTML if openid_service.openid
			<link rel="openid.server" href="#{h openid_service.openid[0]}">
			<link rel="openid.delegate" href="#{h openid_service.openid[1].sub( /<ID>/, openid_id )}">
			HTML
			result << <<-HTML if openid_service.openid2
			<link rel="openid2.provider" href="#{h openid_service.openid2[0]}">
			<link rel="openid2.local_id" href="#{h openid_service.openid2[1].sub( /<ID>/, openid_id )}">
			HTML
			result << <<-HTML if openid_service.x_xrds_location
			<meta http-equiv="X-XRDS-Location" content="#{h openid_service.x_xrds_location.sub( /<ID>/, openid_id )}">
			HTML
			result.gsub( /^\t{2}/, '' )
		end if openid_service
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
