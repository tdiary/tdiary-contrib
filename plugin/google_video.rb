# google_video.rb: Google Video plugin for tDiary
#
# usage: <%= google_video 'DOC_ID' %>
#        <%= google_video 'DOC_ID', 'WIDTHxHEIGHT', %>
#
# otions: following parameters are passed to the player URL.
#         see http://googlesystem.blogspot.com/2006/11/customize-embedded-google-video-player.html for more detail
#
#   @options['google_video.size'] : default of player size.
#                                   (width x height. e.g. '425x320').
#   @options['google_video.height'] : default height
#   @options['google_video.playerMode'] : one of 'embedded', 'simple',
#                                               'mini', 'clickToPlay'
#   @options['google_video.autoPlay'] : true or false
#   @options['google_video.loop'] : true or false
#   @options['google_video.showShareButtons'] : true or false
#
# Copyright (C) 2007 by KAKUTANI Shintaro <shintaro@kakutani.com>
# You can redistribute it and/or modify it under GPL2.
#
# Acknowledgements:
#  * Thanks to omo for extra_options and add_config_proc.

@google_video_conf_label = "Google Video"
@google_video_default_width = 425
@google_video_default_height = 320
@google_video_default_size = "#{@google_video_default_width}x#{@google_video_default_height}"
@google_video_modes = ['embedded', 'simple', 'mini', 'clickToPlay']

def google_video_extra_options(opt)
	playerMode =  opt['google_video.playerMode']
	autoPlay = opt['google_video.autoPlay']
	loop =  opt['google_video.loop']
	showShareButtons =  opt['google_video.showShareButtons']
	ret = ""
	ret += "&playerMode=#{playerMode}" if playerMode
	ret += "&autoPlay=#{autoPlay}" if autoPlay
	ret += "&loop=#{loop}" if loop
	ret += "&showShareButtons=#{showShareButtons}" if showShareButtons
	ret
end

def google_video( doc_id, player_size=nil)
	size = (player_size || @conf['google_video.size'] || @google_video_default_size)
	width, height =
		begin
			size.match(/(\d+)\s*x\s*(\d+)/i)[1..-1].map {|e| Integer(e)}
		rescue
			[@google_video_default_width, @google_video_default_height]
	end

	url = "http://video.google.com/googleplayer.swf?docId=#{doc_id}&hl=en"
	url += google_video_extra_options(@conf)
	<<-TAG
   <object class="googlevideo" width="#{width}" height="#{height}"><param name="movie" value="#{url}"></param
   ><embed src="#{url}" type="application/x-shockwave-flash" width="#{width}" height="#{height}"
   ></embed></object>
	TAG
end

def google_video_conf_proc
	if @mode == 'saveconf' then
		@conf['google_video.size'] = @cgi.params['google_video.size'][0]
		@conf['google_video.autoPlay'] = @cgi.params['google_video.autoPlay'][0] == 'true'
		@conf['google_video.loop'] = @cgi.params['google_video.loop'][0] == 'true'
		@conf['google_video.showShareButtons'] = @cgi.params['google_video.showShareButtons'][0] == 'true'
		@conf['google_video.playerMode'] = @google_video_modes[(@google_video_modes.index(@cgi.params['google_video.playerMode'][0]) or 0)]
	end

	<<-HTML
   <h3>Player size</h3>
   <p>Specify player pixcel size w/ 'width x height' string(e.g. '425x320').</p>
   <p><input name="google_video.size" value="#{CGI::escapeHTML(@conf['google_video.size'] || @google_video_default_size)}" /></p>
   </ul>
   <h3>Player Mode</h3>
   <p><select name="google_video.playerMode">
         <option value="embedded"#{if @conf['google_video.playerMode'] == 'embedded' then ' selected' end}>embedded(default)</option>
         <option value="simple"#{if @conf['google_video.playerMode'] == 'simple' then ' selected' end}>simple</option>
         <option value="mini"#{if @conf['google_video.playerMode'] == 'mini' then ' selected' end}>mini</option>
         <option value="clickToPlay"#{if @conf['google_video.playerMode'] == 'clickToPlay' then ' selected' end}>clickToPlay</option>
   </select>
   <h3>Other Options</h3>
   <p><input type="checkbox" name="google_video.autoPlay" value="true" #{if @conf['google_video.autoPlay'] then ' checked' end}> autoPlay </input></p>
   <p><input type="checkbox" name="google_video.loop" value="true" #{if @conf['google_video.loop'] then ' chec' end}> loop </input></>
   <p><input type="checkbox" name="google_video.showShareButtons" value="true" #{if @conf['google_video.showShareButtons'] then ' checked' end}> showShareButtons </input></p>
	HTML
end

add_conf_proc( 'google_video', @google_video_conf_label ) do
	google_video_conf_proc
end
