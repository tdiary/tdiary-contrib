$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
require 'time'

describe "jmonth plugin" do
	def setup_jmonth_plugin(date)
		fake_plugin(:jmonth) { |plugin|
			plugin.date = date
		}
	end

	describe "in Janu" do
		before do
			@date = Time.parse('20070101');
			@plugin = setup_jmonth_plugin(@date)
		end

		it { @plugin.date.strftime("%i").should  == "睦月" }
	end

	describe "in " do
		before do
			@date = Time.parse('20070201');
			@plugin = setup_jmonth_plugin(@date)
		end

		it { @plugin.date.strftime("%i").should  == "如月" }
	end

	describe "in " do
		before do
			@date = Time.parse('20070301');
			@plugin = setup_jmonth_plugin(@date)
		end

		it { @plugin.date.strftime("%i").should  == "弥生" }
	end

	describe "in Janu" do
		before do
			@date = Time.parse('20070401');
			@plugin = setup_jmonth_plugin(@date)
		end

		it { @plugin.date.strftime("%i").should  == "卯月" }
	end

	describe "in " do
		before do
			@date = Time.parse('20070501');
			@plugin = setup_jmonth_plugin(@date)
		end

		it { @plugin.date.strftime("%i").should  == "皐月" }
	end

	describe "in " do
		before do
			@date = Time.parse('20070601');
			@plugin = setup_jmonth_plugin(@date)
		end

		it { @plugin.date.strftime("%i").should  == "水無月" }
	end

	describe "in Janu" do
		before do
			@date = Time.parse('20070701');
			@plugin = setup_jmonth_plugin(@date)
		end

		it { @plugin.date.strftime("%i").should  == "文月" }
	end

	describe "in " do
		before do
			@date = Time.parse('20070801');
			@plugin = setup_jmonth_plugin(@date)
		end

		it { @plugin.date.strftime("%i").should  == "葉月" }
	end

	describe "in " do
		before do
			@date = Time.parse('20070901');
			@plugin = setup_jmonth_plugin(@date)
		end

		it { @plugin.date.strftime("%i").should  == "長月" }
	end

	describe "in Janu" do
		before do
			@date = Time.parse('20071001');
			@plugin = setup_jmonth_plugin(@date)
		end

		it { @plugin.date.strftime("%i").should  == "神無月" }
	end

	describe "in " do
		before do
			@date = Time.parse('20071101');
			@plugin = setup_jmonth_plugin(@date)
		end

		it { @plugin.date.strftime("%i").should  == "霜月" }
	end

	describe "in " do
		before do
			@date = Time.parse('20071201');
			@plugin = setup_jmonth_plugin(@date)
		end

		it { @plugin.date.strftime("%i").should  == "師走" }
	end
end
