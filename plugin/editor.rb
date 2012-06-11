#
# editor.rb - support writing using wiki/gfm notation.
#
# Copyright (c) 2012 MATSUOKA Kohei <kmachu@gmail.com>
# You can distribute it under GPL.
#

# load javascript
if /\A(form|edit|preview|showcomment)\z/ === @mode then
	enable_js('editor.js')
end
