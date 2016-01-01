$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe "google_analytics plugin" do
	def setup_google_analytics_plugin(profile_id, mode)
		fake_plugin(:google_analytics) { |plugin|
			plugin.mode = mode
			plugin.conf['google_analytics.profile'] = profile_id
		}
	end

	describe "should render javascript" do
		before do
			@plugin = setup_google_analytics_plugin('53836-1', 'latest')
		end

		it "for footer" do
			snippet = @plugin.footer_proc
			expect(snippet).to eq(expected_html_footer_snippet)
		end
	end

	describe "should render javascript" do
		before do
			@plugin = setup_google_analytics_plugin('53836-1', 'conf')
		end

		it "for footer" do
			snippet = @plugin.footer_proc
			expect(snippet).to be_empty
		end
	end

	describe "should not render when profile_id is empty" do
		before do
			@plugin = setup_google_analytics_plugin(nil, 'latest')
		end

		it "for footer" do
			snippet = @plugin.footer_proc
			expect(snippet).to be_empty
		end
	end

	def expected_html_footer_snippet
		expected = <<-SCRIPT
		<script>
			(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
			(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
			m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
			})(window,document,'script','//www.google-analytics.com/analytics.js','ga');

			ga('create', 'UA-53836-1', 'auto');
			ga('send', 'pageview');
		// --></script>
		SCRIPT
		expected.gsub( /^\t/, '' ).chomp
	end
end
