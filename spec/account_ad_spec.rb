$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe "account_ad plugin w/" do
	def setup_account_ad_plugin(service, name)
		fake_plugin(:account_ad) { |plugin|
			plugin.mode = 'latest'
			plugin.conf['account.service'] = service
			plugin.conf['account.name'] = name
			plugin.conf['base_url'] = 'http://www.hsbt.org/diary/'
		}
	end

	describe "Hatena" do
		before do
			plugin = setup_account_ad_plugin('Hatena', 'hsbt')
			@header_snippet = plugin.header_proc
		end

		it { @header_snippet.should include_account_service_with(
				:service => 'http://www.hatena.ne.jp/')}

		it { @header_snippet.should include_account_name_with(
				:name => 'hsbt')}

	end

	def include_account_service_with(options)
		msg = "include #{options[:service]}"
		expected = %|<foaf:accountServiceHomepage rdf:resource="#{options[:service]}"/>|
			Spec::Matchers::SimpleMatcher.new(msg) do |actual|
			actual.include?(expected)
		end
	end

	def include_account_name_with(options)
		msg = "include #{options[:name]}"
		expected = %|<foaf:OnlineAccount foaf:accountName="#{options[:name]}">|
			Spec::Matchers::SimpleMatcher.new(msg) do |actual|
			actual.include?(expected)
		end
	end

end
