#
# twitpic.rb: plugin to insert images on twitpic.com.
#
# Copyright (C) 2010 TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2.
#

def twitpic( image_id, label = 'image on Twitpic', place = 'photo' )
	%Q|<a class="twitpic" href="http://twitpic.com/#{h image_id}" title="#{h label}"><img class="#{h place}", src="http://twitpic.com/show/thumb/#{h image_id}.jpg" width="150" height="150" alt="#{h label}"></a>|
end
