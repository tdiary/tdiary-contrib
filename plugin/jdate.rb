# jdate.rb $Revision: 1.1 $
#
#「%J」で日本語の曜日名を出す
#    pluginに入れるだけで動作する。
#    日付フォーマットなどで「%J」を指定するとそこが日本語の曜日になる
#
# Copyright (c) 2003 TADA Tadashi <sho@spc.gr.jp>
# You can distribute this file under the GPL.
#
unless Time::new.respond_to?( :strftime_jdate_backup ) then
	eval( <<-MODIFY_CLASS, TOPLEVEL_BINDING )
		class Time
		   alias strftime_jdate_backup strftime
		   JWDAY = %w(日 月 火 水 木 金 土)
		   def strftime( format )
		      strftime_jdate_backup( format.gsub( /%J/, JWDAY[self.wday] ) )
		   end
		end
	MODIFY_CLASS
end
