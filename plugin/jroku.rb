# jroku.rb $Revision: 1.1 $
#
#「%R」で六曜を出す
#    動かすためには
#    http://www.funaba.org/calendar.html#calendar
#    で配布されているClendarモジュールと付属しているcalclass.rbが必要
#    日付フォーマットなどで「%R」を指定するとそこが六曜になる
#
# Copyright (c) 2005 SHIBATA Hiroshi <h-sbt@nifty.com>
# You can distribute this file under the GPL.
#
require 'calclass.rb'

unless Time::new.respond_to?( :strftime_jroku_backup ) then
   eval( <<-MODIFY_CLASS, TOPLEVEL_BINDING )
   class Time
      alias strftime_jroku_backup strftime
      JROKU = %w(大安 赤口 先勝 友引 先負 仏滅)
      
      def strftime( format )
         d=Gregorian.new(self.month, self.day, self.year)
         q_d = Calendar.kyureki_from_absolute(d.abs)
         index = (q_d[0] + q_d[2]) % 6
         strftime_jroku_backup( format.gsub( /%R/, JROKU[index] ) )
      end
   end
   MODIFY_CLASS
end
