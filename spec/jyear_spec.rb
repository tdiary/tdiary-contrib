# -*- coding: utf-8 -*-

$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
require 'time'

describe "jyear plugin" do
  {
    '1925/01/01' => '昔々',
    '1926/12/25' => '昭和元年',
    '1927/01/01' => '昭和2',
    '1989/01/08' => '平成元年',
    '1990/01/01' => '平成2',
  }.each do |k,v|
    it { setup_jyear_plugin(Time.parse(k)).date.strftime('%K').should == v }
  end

  def setup_jyear_plugin(date)
    fake_plugin(:jyear) { |plugin| plugin.date = date }
  end
end
