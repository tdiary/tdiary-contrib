# show photo image on Picasa Web Album
#
# usage:
#   picasa( src[, title[, place]] )
#     - src: The url of the photo to show.
#     - title: title of photo. (optional)
#     - place: class name of img element. default is 'photo'.
#
#   picasa_left( src[, title] )
#
#   picasa_right( src[, title] )
#
# options configurable through settings:
#   @conf['picasa.user'] : picasa username
#   @conf['picasa.default_size'] : default image size
#
# Copyright (c) hb <http://www.smallstyle.com>
# Distributed under the GPL.
#

def picasa( src, alt = "photo", place = 'photo' )
	%Q|<img title="#{alt}" alt="#{alt}" src="#{src}" class="#{place} picasa">|
end

def picasa_left( src, alt = "photo" )
	picasa( src, alt, 'left' )
end

def picasa_right( src, alt = "photo" )
	picasa( src, alt, 'right' )
end
