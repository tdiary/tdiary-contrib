# -*- coding: utf-8 -*-

$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
require 'time'

describe "jdate plugin" do
  {
    '20080121' => '月',
    '20080122' => '火',
    '20080123' => '水',
    '20080124' => '木',
    '20080125' => '金',
    '20080126' => '土',
    '20080127' => '日',
  }.each do |k,v|
    it { setup_jdate_plugin(Time.parse(k)).date.strftime('%J').should == v }
  end

  def setup_jdate_plugin(date)
    fake_plugin(:jdate) {|plugin| plugin.date = date}
  end
end
