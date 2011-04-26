$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe "openid plugin w/" do
	def setup_open_id_plugin(service, userid)
		fake_plugin(:openid) { |plugin|
			plugin.mode = 'latest'
			plugin.conf['openid.service'] = service
			plugin.conf['openid.id'] = userid
		}
	end

	describe "Hatena" do
		before do
			plugin = setup_open_id_plugin('Hatena', 'tdtds')
			@header_snippet = plugin.header_proc
		end

		it { @header_snippet.should include_link_tag_with(
				:rel => 'openid.server',
				:href => 'https://www.hatena.ne.jp/openid/server')}

		it { @header_snippet.should include_link_tag_with(
				:rel => 'openid.delegate',
				:href => 'http://www.hatena.ne.jp/tdtds/')}
	end

	describe "livedoor" do
		before do
			plugin = setup_open_id_plugin('livedoor', 'tdtds')
			@header_snippet = plugin.header_proc
		end

		it { @header_snippet.should include_link_tag_with(
				:rel => 'openid.server',
				:href => 'http://auth.livedoor.com/openid/server')}

		it { @header_snippet.should include_link_tag_with(
			:rel => 'openid.delegate',
			:href => 'http://profile.livedoor.com/tdtds')}
	end

	describe "LiveJournal" do
		before do
			plugin = setup_open_id_plugin('LiveJournal', 'tdtds')
			@header_snippet = plugin.header_proc
		end

		it { @header_snippet.should include_link_tag_with(
				:rel => 'openid.server',
				:href => 'http://www.livejournal.com/openid/server.bml')}

		it { @header_snippet.should include_link_tag_with(
				:rel => 'openid.delegate',
				:href => 'http://tdtds.livejournal.com/')}

	end

	describe "OpenID.ne.jp" do
		before do
			plugin = setup_open_id_plugin('OpenID.ne.jp', 'tdtds')
			@header_snippet = plugin.header_proc
		end

		it { @header_snippet.should include_link_tag_with(
				:rel => 'openid.server',
				:href => 'http://www.openid.ne.jp/user/auth')}

		it { @header_snippet.should include_link_tag_with(
				:rel => 'openid.delegate',
				:href => 'http://tdtds.openid.ne.jp')}

		it { @header_snippet.should include_xrds_meta_tag_with(
				:content => 'http://tdtds.openid.ne.jp/user/xrds')}

	end

	describe "TypeKey" do
		before do
			plugin = setup_open_id_plugin('TypeKey', 'tdtds')
			@header_snippet = plugin.header_proc
		end

		it { @header_snippet.should include_link_tag_with(
				:rel => 'openid.server',
				:href => 'http://www.typekey.com/t/openid/')}

		it { @header_snippet.should include_link_tag_with(
				:rel => 'openid.delegate',
				:href => 'http://profile.typekey.com/tdtds/')}

	end

	describe "Vox" do
		before do
			plugin = setup_open_id_plugin('Vox', 'tdtds')
			@header_snippet = plugin.header_proc
		end

		it { @header_snippet.should include_link_tag_with(
				:rel => 'openid.server',
				:href => 'http://www.vox.com/services/openid/server')}

		it { @header_snippet.should include_link_tag_with(
				:rel => 'openid.delegate',
				:href => 'http://tdtds.vox.com/')}
	end

	describe "myopenid.com" do
		before do
			@plugin = setup_open_id_plugin('myopenid.com', 'tdtds')
			@header_snippet = @plugin.header_proc
		end

		it { @header_snippet.should include_xrds_meta_tag_with(
				:content => "http://www.myopenid.com/xrds?username=tdtds")}

		it { @header_snippet.should include_link_tag_with(
				:rel => "openid.server",
				:href => "http://www.myopenid.com/server")}

		it { @header_snippet.should include_link_tag_with(
				:rel => "openid.delegate",
				:href => "http://tdtds.myopenid.com")}

		it { @header_snippet.should include_link_tag_with(
				:rel => "openid2.provider",
				:href => "http://www.myopenid.com/server")}

		it { @header_snippet.should include_link_tag_with(
				:rel => "openid2.local_id",
				:href => "http://tdtds.myopenid.com")}
	end

	describe "claimID.com" do
		before do
			@plugin = setup_open_id_plugin('claimID.com', 'tdtds')
			@header_snippet = @plugin.header_proc
		end

		it { @header_snippet.should include_xrds_meta_tag_with(
				:content => "http://claimid.com/tdtds/xrds")}

		it { @header_snippet.should include_link_tag_with(
				:rel => "openid.server",
				:href => "http://openid.claimid.com/server")}

		it { @header_snippet.should include_link_tag_with(
				:rel => "openid.delegate",
				:href => "http://openid.claimid.com/tdtds")}
	end

	describe "Personal Identity Provider (PIP)" do
		before do
			@plugin = setup_open_id_plugin('Personal Identity Provider (PIP)', 'tdtds')
			@header_snippet = @plugin.header_proc
		end

		it { @header_snippet.should include_xrds_meta_tag_with(
				:content => "http://pip.verisignlabs.com/user/tdtds/yadisxrds")}

		it { @header_snippet.should include_link_tag_with(
				:rel => "openid.server",
				:href => "http://pip.verisignlabs.com/server")}

		it { @header_snippet.should include_link_tag_with(
				:rel => "openid.delegate",
				:href => "http://tdtds.pip.verisignlabs.com/")}

		it { @header_snippet.should include_link_tag_with(
				:rel => "openid2.provider",
				:href => "http://pip.verisignlabs.com/server")}

		it { @header_snippet.should include_link_tag_with(
				:rel => "openid2.local_id",
				:href => "http://tdtds.pip.verisignlabs.com/")}
	end

	describe "Yahoo! Japan" do
		before do
			plugin = setup_open_id_plugin('Yahoo! Japan', 'tdtds')
			@header_snippet = plugin.header_proc
		end

		it { @header_snippet.should include_link_tag_with(
				:rel => 'openid2.provider',
				:href => 'https://open.login.yahooapis.jp/openid/op/auth')}

		it { @header_snippet.should include_link_tag_with(
				:rel => 'openid2.local_id',
				:href => 'https://me.yahoo.co.jp/a/tdtds')}

		it { @header_snippet.should_not include_link_tag_with(
				:rel => "openid.server")}

		it { @header_snippet.should_not include_link_tag_with(
				:rel => "openid.delegate")}

	end

	describe "Yahoo!" do
		before do
			plugin = setup_open_id_plugin('Yahoo!', 'tdtds')
			@header_snippet = plugin.header_proc
		end

		it { @header_snippet.should include_link_tag_with(
				:rel => 'openid2.provider',
				:href => 'https://open.login.yahooapis.com/openid/op/auth')}

		it { @header_snippet.should include_link_tag_with(
				:rel => 'openid2.local_id',
				:href => 'https://me.yahoo.com/a/tdtds')}

		it { @header_snippet.should_not include_link_tag_with(
				:rel => "openid.server")}

		it { @header_snippet.should_not include_link_tag_with(
				:rel => "openid.delegate")}
	end

	describe "Wassr" do
		before do
			plugin = setup_open_id_plugin('Wassr', 'tdtds')
			@header_snippet = plugin.header_proc
		end

		it { @header_snippet.should include_link_tag_with(
				:rel => 'openid.server',
				:href => 'https://wassr.jp/open_id/auth')}

		it { @header_snippet.should include_link_tag_with(
				:rel => 'openid.delegate',
				:href => 'https://wassr.jp/user/tdtds')}
	end

	RSpec::Matchers.define :include_link_tag_with do |options|
    description do
      "include #{options[:rel]} link tag"
    end

		match do |actual|
      expected = %|<link rel="#{options[:rel]}"| if options[:rel]
      expected <<= %| href="#{options[:href]}">| if options[:href]
			actual.include?( expected )
		end
	end

	RSpec::Matchers.define :include_xrds_meta_tag_with do |options|
    description do
      "include XRDS meta tag"
    end

		match do |actual|
      expected = (<<-"EOS").chomp
<meta http-equiv="X-XRDS-Location" content="#{options[:content]}">
      EOS
			actual.include?( expected )
		end
	end
end
