$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
require 'time'

describe "jmonth plugin" do
  with_fixtures :date => :jmonth do
    def setup_jmonth_plugin(date)
      fake_plugin(:jmonth) { |plugin|
        plugin.date = date
      }
    end

    filters({
      :date => lambda {|val| Time.parse(val) }
    })

    it 'in :jmonth' do |date, jmonth|
      setup_jmonth_plugin(date).date.strftime('%i').should == jmonth
    end

    set_fixtures([
      [ '2007/01/01' => '睦月'] ,
      [ '2007/02/01' => '如月'] ,
      [ '2007/03/01' => '弥生'] ,
      [ '2007/04/01' => '卯月'] ,
      [ '2007/05/01' => '皐月'] ,
      [ '2007/06/01' => '水無月' ] ,
      [ '2007/07/01' => '文月'] ,
      [ '2007/08/01' => '葉月'] ,
      [ '2007/09/01' => '長月'] ,
      [ '2007/10/01' => '神無月'],
      [ '2007/11/01' => '霜月'] ,
      [ '2007/12/01' => '師走'] ,
    ]) 
  end
end
