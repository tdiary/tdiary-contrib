$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe "google_analytics plugin" do
	def setup_google_analytics_plugin(profile_id)
		fake_plugin(:google_analytics) { |plugin|
			plugin.conf['google_analytics.profile'] = profile_id
		}
	end

	describe "should render javascript" do
		before do
			@plugin = setup_google_analytics_plugin('53836-1')
		end
		
		it "for footer" do
			snippet = @plugin.footer_proc
			snippet.should == expected_html_footer_snippet
		end
	end

	describe "should not render when profile_id is empty" do
		before do
			@plugin = setup_google_analytics_plugin(nil)
		end
		
		it "for footer" do
			snippet = @plugin.footer_proc
			snippet.should be_empty
		end
	end

	def expected_html_footer_snippet
		expected = <<-SCRIPT
		<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
		</script>
		<script type="text/javascript">
		_uacct = "UA-53836-1";
		urchinTracker();
		</script>
		SCRIPT
		expected.gsub( /^\t/, '' ).chomp
	end
end
