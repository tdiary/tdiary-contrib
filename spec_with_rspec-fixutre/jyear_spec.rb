$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
require 'time'

describe "jyear plugin" do
  with_fixtures :date => :jyear do
    def setup_jyear_plugin(date)
      fake_plugin(:jyear) { |plugin|
        plugin.date = date
      }
    end

    it 'in :date' do |date, jyear|
      setup_jyear_plugin(date).date.strftime('%K').should == jyear
    end

    filters({
      :date => lambda {|val| Time.parse(val) },
    })

    set_fixtures([
      ['1925/01/01' => '昔々'],
      ['1926/12/25' => '昭和元年'],
      ['1927/01/01' => '昭和2' ],
      ['1989/01/08' => '平成元年' ],
      ['1990/01/01' => '平成2' ],
    ])
  end
end
