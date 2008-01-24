$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
require 'time'

describe "jdate plugin" do
	def setup_jdate_plugin(date)
		fake_plugin(:jdate) { |plugin|
			plugin.date = date
		}
	end

	describe "for monday" do
		before do
			@date = Time.parse('20080121');
			@plugin = setup_jdate_plugin(@date)
		end

		it { @plugin.date.strftime("%J").should  == "月" }
	end

	describe "for tuesday" do
		before do
			@date = Time.parse('20080122');
			@plugin = setup_jdate_plugin(@date)
		end

		it { @plugin.date.strftime("%J").should  == "火" }
	end

	describe "for wednesday" do
		before do
			@date = Time.parse('20080123');
			@plugin = setup_jdate_plugin(@date)
		end

		it { @plugin.date.strftime("%J").should  == "水" }
	end

	describe "for thursday" do
		before do
			@date = Time.parse('20080124');
			@plugin = setup_jdate_plugin(@date)
		end

		it { @plugin.date.strftime("%J").should  == "木" }
	end

	describe "for friday" do
		before do
			@date = Time.parse('20080125');
			@plugin = setup_jdate_plugin(@date)
		end

		it { @plugin.date.strftime("%J").should  == "金" }
	end

	describe "for saturday" do
		before do
			@date = Time.parse('20080126');
			@plugin = setup_jdate_plugin(@date)
		end

		it { @plugin.date.strftime("%J").should  == "土" }
	end

	describe "for sunday" do
		before do
			@date = Time.parse('20080127');
			@plugin = setup_jdate_plugin(@date)
		end

		it { @plugin.date.strftime("%J").should  == "日" }
	end
end
