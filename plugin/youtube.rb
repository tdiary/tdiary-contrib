#
# youtube.rb: YouTube plugin for tDiary
#
# Copyright (C) 2007 by TADA Tadashi <sho@spc.gr.jp>
#
# usage: <%= youtube 'VIDEO_ID' %>
#
def youtube( video_id )
	if @conf.mobile_agent? then
		%Q|<div class="youtube"><a href="http://www.youtube.com/watch?v=#{video_id}">YouTube (#{video_id})</a></div>|
	elsif defined?( :iphone? ) and iphone?
		%Q|<div class="youtube"><a href="youtube:#{video_id}">YouTube (#{video_id})</a></div>|
	else
		<<-TAG
		<object width="425" height="350"><param name="movie" value="http://www.youtube.com/v/#{video_id}"></param><embed src="http://www.youtube.com/v/#{video_id}" type="application/x-shockwave-flash" width="425" height="350"></embed></object>
		TAG
	end
end
