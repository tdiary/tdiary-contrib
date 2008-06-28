# navi-this-month.rb
# ref. http://www.tom.sfc.keio.ac.jp/~sakai/d/?date=20080628#p01
#
alias navi_this_month__orig__navi_user_day navi_user_day

def navi_user_day
  result = navi_this_month__orig__navi_user_day
	if @mode=='day'
    this_month = @date.strftime( '%Y%m' )
		result << navi_item( "#{@index}#{anchor this_month}", "#{navi_this_month}" )
  end
  result
end

def navi_this_month; "月表示"; end
