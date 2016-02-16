#
# youtube.rb: YouTube plugin for tDiary
#
# Copyright (C) 2010 by TADA Tadashi <t@tdtds.jp>
#
# usage: <%= youtube 'VIDEO_ID' %>
#
def youtube( video_id, size = [425,350] )
	if feed?
		%Q|<div class="youtube"><a href="//www.youtube.com/watch?v=#{video_id}">YouTube (#{video_id})</a></div>|
	else
		<<-TAG
		<div class="youtube-player-wrapper">
		<iframe class="youtube-player" type="text/html" width="#{size[0]}" height="#{size[1]}" src="//www.youtube.com/embed/#{video_id}" frameborder="0">
		</iframe>
		</div>
		TAG
	end
end

def youtube_custom( video_id, size = [416,337] )
  <<-TAG
  <div class="youtube-player-wrapper">
  <object width="#{size[0]}" height="#{size[1]}">
  <param name="movie" value="//www.youtube.com/cp/#{video_id}"></param>
  <embed src="//www.youtube.com/cp/#{video_id}" type="application/x-shockwave-flash" width="#{size[0]}" height="#{size[1]}"></embed>
  </object>
  </div>
  TAG
end
