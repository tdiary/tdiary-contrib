$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
require 'time'

describe "account_ad plugin" do
	def setup_account_ad_plugin(service, name, mode)
		fake_plugin(:account_ad) { |plugin|
			plugin.mode = mode
			plugin.conf['account.service'] = service
			plugin.conf['account.name'] = name
			plugin.conf['base_url'] = 'http://www.hsbt.org/diary/'
			plugin.date = Time.parse("20070120")
		}
	end

	describe "Hatena" do
		describe "in day mode" do
			before do
				plugin = setup_account_ad_plugin('Hatena', 'hsbt', 'day')
				@header_snippet = plugin.header_proc
			end

			it { @header_snippet.should include_description_about_with(
					:permalink => 'http://www.hsbt.org/diary/?date=20070120')}

			it { @header_snippet.should include_account_service_with(
					:service => 'http://www.hatena.ne.jp/')}

			it { @header_snippet.should include_account_name_with(
					:name => 'hsbt')}
		end

		describe "in latest mode" do
			before do
				plugin = setup_account_ad_plugin('Hatena', 'hsbt', 'latest')
				@header_snippet = plugin.header_proc
			end

			it { @header_snippet.should include_description_about_with(
					:permalink => 'http://www.hsbt.org/diary/')}

			it { @header_snippet.should include_account_service_with(
					:service => 'http://www.hatena.ne.jp/')}

			it { @header_snippet.should include_account_name_with(
					:name => 'hsbt')}
		end

		describe "in configuration mode" do
			before do
				@plugin = setup_account_ad_plugin('Hatena', 'hsbt', 'conf')
			end

			it "should not raise error" do
				lambda{@plugin.conf_proc}.should_not raise_error
			end
		end
	end

	RSpec::Matchers.define :include_description_about_with do |options|
    description do
      "include #{options[:permalink]}"
    end

    match do |actual|
      expected = %|<rdf:Description rdf:about="#{options[:permalink]}">|
			actual.include?(expected)
		end
	end

	RSpec::Matchers.define :include_account_service_with do |options|
    description do
      "include #{options[:service]}"
    end

    match do |actual|
      expected = %|<foaf:accountServiceHomepage rdf:resource="#{options[:service]}" />|
			actual.include?(expected)
		end
	end

	RSpec::Matchers.define :include_account_name_with do |options|
    description do
      "include #{options[:name]}"
    end

    match do |actual|
      expected = %|<foaf:OnlineAccount foaf:accountName="#{options[:name]}">|
			actual.include?(expected)
		end
	end
end
