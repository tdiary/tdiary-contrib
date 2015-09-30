# -*- coding: utf-8; -*-
#
# preview.rb: view preview automatically
#
# Copyright (c) MATSUOKA Kohei <http://www.machu.jp/>
# Distributed under the GPL2 or any later version.
#
if /\A(form|edit|preview)\z/ === @mode then
	enable_js('preview.js')
end
