$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
require 'time'

describe "jyear plugin" do
	def setup_jyear_plugin(date)
		fake_plugin(:jyear) { |plugin|
			plugin.date = date
		}
	end

	describe "in 1925/01/01" do
		before do
			@date = Time.parse('19250101');
			@plugin = setup_jyear_plugin(@date)
		end

		it { @plugin.date.strftime("%K").should  == "昔々" }
	end

	describe "in 1926/12/25" do
		before do
			@date = Time.parse('19261225');
			@plugin = setup_jyear_plugin(@date)
		end

		it { @plugin.date.strftime("%K").should  == "昭和元年" }
	end

	describe "in 1927/01/01" do
		before do
			@date = Time.parse('19270101');
			@plugin = setup_jyear_plugin(@date)
		end

		it { @plugin.date.strftime("%K").should  == "昭和2" }
	end

	describe "in 1981/01/08" do
		before do
			@date = Time.parse('19890108');
			@plugin = setup_jyear_plugin(@date)
		end

		it { @plugin.date.strftime("%K").should  == "平成元年" }
	end

	describe "in 1990/01/01" do
		before do
			@date = Time.parse('19900101');
			@plugin = setup_jyear_plugin(@date)
		end

		it { @plugin.date.strftime("%K").should  == "平成2" }
	end

end
