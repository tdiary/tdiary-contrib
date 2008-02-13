$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
require 'time'

describe "jdate plugin" do

	with_fixtures :date => :jwday do
    def setup_jdate_plugin(date)
      fake_plugin(:jdate) { |plugin|
        plugin.date = date
      }
    end

    filters({
      :date => lambda {|val| Time.parse(val) },
    })

    it ':jwday' do |date, jwday|
      setup_jdate_plugin(date).date.strftime('%J').should == jwday
    end

    set_fixtures([
      [ '20080121' => '月'],
      [ '20080122' => '火'],
      [ '20080123' => '水'],
      [ '20080124' => '木'],
      [ '20080125' => '金'],
      [ '20080126' => '土'],
      [ '20080127' => '日'],
    ])
	end
end

