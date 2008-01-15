#	jyear.rb $Revision: 1.1 $
#	
#	西暦を和暦に変換するプラグイン。
#	日記やツッコミの日付フォーマットで使う。
#	「%Y」で「2005」のところを、「%K」で「平成17」と表示。
#	pluginに入れるだけで動作する。
#	
# Copyright (c) 2005 sasasin/SuzukiShinnosuke<sasasin@sasasin.sytes.net>
# You can distribute this file under the GPL.
#

unless Time::new.respond_to?( :strftime_jyear_backup ) then
	eval( <<-MODIFY_CLASS, TOPLEVEL_BINDING )
		class Time
			alias strftime_jyear_backup strftime
			def strftime( format )
				case self.year
					when 0 .. 1926
						gengo = "昔々"
						if self.year = 1926 && self.month = 12 && self.wday >=25 then
							gengo = "昭和元年"
						end
					when 1927 .. 1989
						jyear = self.year - 1925
						gengo = "昭和" + jyear.to_s
						if self.year = 1989 && self.month = 1 && self.wday >= 8 then
							gengo = "平成元年"
						end
					else
						jyear = self.year - 1988
						gengo = "平成" + jyear.to_s
				end
				strftime_jyear_backup( format.gsub( /%K/, gengo ) )
			end
		end
	MODIFY_CLASS
end