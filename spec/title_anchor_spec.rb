$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe "title_anchor plugin" do
	def setup_title_anchor_plugin(mode)
		fake_plugin(:title_anchor) { |plugin|
			plugin.mode = mode
			plugin.conf.index = ''
			plugin.conf.html_title = "HsbtDiary"
		}
	end

	describe "in day mode" do
		before do
			@plugin = setup_title_anchor_plugin('day')
		end

		it { @plugin.title_anchor.should  == expected_html_title_in_day(
				:index => '',
				:html_title => 'HsbtDiary')}
	end

	describe "in latest mode" do
		before do
			@plugin = setup_title_anchor_plugin('latest')
		end

		it { @plugin.title_anchor.should  == expected_html_title_in_latest(
				:html_title => 'HsbtDiary')}
	end

	def expected_html_title_in_day(options)
		expected = %{<h1><a href="#{options[:index]}">#{options[:html_title]}</a></h1>}
	end

	def expected_html_title_in_latest(options)
		expected = %{<h1>#{options[:html_title]}</h1>}
	end
end
