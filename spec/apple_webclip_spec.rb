$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe "apple_webclip plugin" do
	def setup_apple_webclip_plugin( url )
		fake_plugin(:apple_webclip) { |plugin|
			plugin.conf['apple_webclip.url'] = url
		}
	end

	describe "url is enabled" do
		before do
			plugin = setup_apple_webclip_plugin('http://example.com/example.png')
			@header_snippet = plugin.header_proc
		end

		it "header include url" do
			expect(@header_snippet).to eq(%Q|\t<link rel="apple-touch-icon" href="http://example.com/example.png">|)
		end
	end

	describe "url is disabled" do
		describe "url is empty" do
			before do
				plugin = setup_apple_webclip_plugin('')
				@header_snippet = plugin.header_proc
			end

			it "header is empty" do
				expect(@header_snippet).to be_empty
			end
		end

		describe "url is nil" do
			before do
				plugin = setup_apple_webclip_plugin(nil)
				@header_snippet = plugin.header_proc
			end

			it "header is empty" do
				expect(@header_snippet).to be_empty
			end
		end
	end

end
