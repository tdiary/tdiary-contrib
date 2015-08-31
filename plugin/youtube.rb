#
# youtube.rb: YouTube plugin for tDiary
#
# Copyright (C) 2010 by TADA Tadashi <t@tdtds.jp>
#
# usage: <%= youtube 'VIDEO_ID' %>
#
def youtube( video_id, size = [425,350] )
	if feed?
		%Q|<div class="youtube"><a href="http://www.youtube.com/watch?v=#{video_id}">YouTube (#{video_id})</a></div>|
	elsif defined?( :smartphone? ) and @conf.smartphone?
		size = [240, 194]
		<<-TAG
		<iframe class="youtube-player" type="text/html" width="#{size[0]}" height="#{size[1]}" src="http://www.youtube.com/embed/#{video_id}" frameborder="0">
		</iframe>
		<div class="youtube"><a href="http://www.youtube.com/watch?v=#{video_id}">YouTube (#{video_id})</a></div>
		TAG
	else
		<<-TAG
		<iframe class="youtube-player" type="text/html" width="#{size[0]}" height="#{size[1]}" src="http://www.youtube.com/embed/#{video_id}" frameborder="0">
		</iframe>
		TAG
	end
end

def youtube_custom( video_id, size = [416,337] )
  <<-TAG
  <object width="#{size[0]}" height="#{size[1]}">
  <param name="movie" value="http://www.youtube.com/cp/#{video_id}"></param>
  <embed src="http://www.youtube.com/cp/#{video_id}" type="application/x-shockwave-flash" width="#{size[0]}" height="#{size[1]}"></embed>
  </object>
  TAG
end
