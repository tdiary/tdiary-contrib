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
			snippet.should == expected_html_footer_snippet
		end
	end

	describe "should render javascript" do
		before do
			@plugin = setup_google_analytics_plugin('53836-1', 'conf')
		end

		it "for footer" do
			snippet = @plugin.footer_proc
			snippet.should be_empty
		end
	end

	describe "should not render when profile_id is empty" do
		before do
			@plugin = setup_google_analytics_plugin(nil, 'latest')
		end

		it "for footer" do
			snippet = @plugin.footer_proc
			snippet.should be_empty
		end
	end

	def expected_html_footer_snippet
		expected = <<-SCRIPT
		<script type="text/javascript"><!--
		var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
		document.write(unescape('%3Cscript src="' + gaJsHost + 'google-analytics.com/ga.js" type="text/javascript"%3E%3C/script%3E'));
		// --></script>
		<script type="text/javascript"><!--
		try {
			var pageTracker = _gat._getTracker("UA-53836-1");
			pageTracker._trackPageview();
		} catch (err) {}
		// --></script>
		SCRIPT
		expected.gsub( /^\t/, '' ).chomp
	end
end
