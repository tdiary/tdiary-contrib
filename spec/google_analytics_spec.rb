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
			<!-- Global site tag (gtag.js) - Google Analytics -->
			<script async src="https://www.googletagmanager.com/gtag/js?id=UA-53836-1"></script>
			<script>
				window.dataLayer = window.dataLayer || [];
				function gtag(){dataLayer.push(arguments);}
				gtag('js', new Date());

				gtag('config', 'UA-53836-1');
			</script>
		SCRIPT
		expected.gsub( /^\t/, '' ).chomp
	end
end
