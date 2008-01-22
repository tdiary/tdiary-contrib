$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe "opensearch_ad plugin w/" do
	def setup_opensearch_ad_plugin(title, xml, mode)
		fake_plugin(:opensearch_ad) { |plugin|
			plugin.mode = mode
			plugin.conf['opensearch.title'] = title
			plugin.conf['opensearch.xml'] = xml
		}
	end

	describe "in day mode" do
		before do
			plugin = setup_opensearch_ad_plugin('OpenSearch', 'http://example.com/opensearch.xml', 'day')
			@header_snippet = plugin.header_proc
		end

		it { @header_snippet.should == expected_link_tag_with(
				:title => 'OpenSearch',
				:xml => 'http://example.com/opensearch.xml')}
	end

	describe "in latest mode" do
		before do
			plugin = setup_opensearch_ad_plugin('OpenSearch', 'http://example.com/opensearch.xml', 'latest')
			@header_snippet = plugin.header_proc
		end
		
		it { @header_snippet.should == expected_link_tag_with(
				:title => 'OpenSearch',
				:xml => 'http://example.com/opensearch.xml')}
	end

	describe "in edit mode" do
		before do
			plugin = setup_opensearch_ad_plugin('OpenSearch', 'http://example.com/opensearch.xml', 'edit')
			@header_snippet = plugin.header_proc
		end
		
		it { @header_snippet.should be_empty }
	end

	def expected_link_tag_with(options)
		expected = "\t<link type=\"application/opensearchdescription+xml\" rel=\"search\" title=\"#{options[:title]}\" href=\"#{options[:xml]}\">"
	end
end
