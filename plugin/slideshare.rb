#
# slideshare.rb - insert some services of slideshare.net
#
# Copyright (C) 2011, Kiwamu Okabe <kiwamu@debian.or.jp>.
# You can redistribute it and/or modify it under GPL2.
#

def slideshare( embed_code )
	%Q|<iframe src="http://www.slideshare.net/slideshow/embed_code/#{embed_code}" width="425" height="355" frameborder="0" marginwidth="0" marginheight="0" scrolling="no"></iframe>|
end
