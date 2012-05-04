# editor.rb
#
# Copyright (c) 2012 MATSUOKA Kohei <kmachu@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#

# load javascript
if /\A(form|edit|preview|showcomment)\z/ === @mode then
	enable_js('editor.js')
end
