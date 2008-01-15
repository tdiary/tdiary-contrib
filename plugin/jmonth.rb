# jmonth.rb $Revision: 1.1 $
#
#「%i」で日本語の陰暦月名を出す
#    pluginに入れるだけで動作する。
#    日付フォーマットなどで「%i」を指定するとそこが陰暦月名になる
#
# Copyright (c) 2005 sasasin/SuzukiShinnosuke<sasasin@sasasin.sytes.net>
# You can distribute this file under the GPL.
#
unless Time::new.respond_to?( :strftime_jmonth_backup ) then
	eval( <<-MODIFY_CLASS, TOPLEVEL_BINDING )
		class Time
		   alias strftime_jmonth_backup strftime
		   JMONTH = %w(睦月 如月 弥生 卯月 皐月 水無月 文月 葉月 長月 神無月 霜月 師走)
		   def strftime( format )
		      strftime_jmonth_backup( format.gsub( /%i/, JMONTH[self.month-1] ) )
		   end
		end
	MODIFY_CLASS
end
