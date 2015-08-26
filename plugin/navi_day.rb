#
# navi_day.rb
#
# navi_day: 「前の日記」や「次の日記」を“月またぎ”に対応させる。
#
#   日単位での表示の時の「前の日記」や「次の日記」のリンクが、
#   異なる月の日記を正しく指せない場合があるという tDiary の制限を
#   解消するプラグインです。以前よりある navi_user.rb と機能的には
#   同じですが、navi_user.rb よりは処理がずっと軽くなっています。
#   また、日記の表示状態(非表示の日記)に対する考慮もなされています。
#
#   tDiary 2.0 以降で使えると思います。セキュアモードでも使えますが、
#   セキュアモードの場合は、モバイル端末からのアクセスに対しては
#   このプラグインは効力を持ちません（tDiary セキュア環境の制限：
#   モバイル端末の場合は本文を出力するときに calc_links が呼ばれる
#   ため）。
#
#   navi_user.rb と併用すると navi_user.rb の方が優先されますので、
#   このプラグインを使うときには必ず navi_user.rb を外してください。
#
# Copyright (C) 2007, MIYASAKA Masaru <alkaid@coral.ocn.ne.jp>
# You can redistribute it and/or modify it under GPL2.
#
# Last Modified : May 27, 2007
#

# for tDiary 2.0.X
if not TDiaryMonth.method_defined?(:diaries) then
	eval( <<-MODIFY_CLASS, TOPLEVEL_BINDING )
	module TDiary
		class TDiaryMonth
			attr_reader :diaries
		end
	end
	MODIFY_CLASS
end

class NaviDayCGI
	attr_reader :params
	def referer; nil; end
	def initialize
		@params = Hash.new([])
	end
end

alias :calc_links_navi_day_backup :calc_links

def calc_links
	if not @conf.secure and \
	       (/day|edit/ =~ @mode or \
	        /latest|month|nyear/ =~ @mode) then
		if /(latest|month|nyear)/ === @mode
			today = @diaries.keys.sort[-1]
		else
			today = @date.strftime('%Y%m%d')
		end
		days = @diaries.keys
		days |= [today]
		days.sort!
		days.unshift(nil).push(nil)
		today_index = days.index(today)

		days[0 .. today_index - 1].reverse_each do |prev_day|
			@prev_day = prev_day
			break unless @prev_day
			break if (@mode == 'edit') or @diaries[@prev_day].visible?
		end

		days[today_index + 1 .. -1].each do |next_day|
			@next_day = next_day
			break unless @next_day
			break if (@mode == 'edit') or @diaries[@next_day].visible?
		end

		if not @prev_day or not @next_day then
			cgi = NaviDayCGI.new
			years = []
			@years.each do |k, v|
				v.each do |m|
					years << k + m
				end
			end
			this_month = @date.strftime('%Y%m')
			years |= [this_month]
			years.sort!
			years.unshift(nil).push(nil)
			this_month_index = years.index(this_month)

			years[0 .. this_month_index - 1].reverse_each do |prev_month|
				break unless not @prev_day and prev_month
				cgi.params['date'] = [prev_month]
				diaries = TDiaryMonth.new(cgi, '', @conf).diaries
				days = diaries.keys.sort
				days.unshift(nil)
				days.reverse_each do |prev_day|
					@prev_day = prev_day
					break unless @prev_day
					break if (@mode == 'edit') or diaries[@prev_day].visible?
				end
			end

			years[this_month_index + 1 .. -1].each do |next_month|
				break unless not @next_day and next_month
				cgi.params['date'] = [next_month]
				diaries = TDiaryMonth.new(cgi, '', @conf).diaries
				days = diaries.keys.sort
				days.push(nil)
				days.each do |next_day|
					@next_day = next_day
					break unless @next_day
					break if (@mode == 'edit') or diaries[@next_day].visible?
				end
			end
		end
	else
		calc_links_navi_day_backup
	end
end
