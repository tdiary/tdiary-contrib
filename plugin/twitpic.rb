#
# twitpic.rb: plugin to insert images on twitpic.com.
#
# Copyright (C) 2010 TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2.
#

def twitpic(image_id, label = 'Image on Twitpic', place = 'photo')
	%Q|<p><a class="twitpic" href="http://twitpic.com/#{h image_id}">#{h label}</a></p>|
end
