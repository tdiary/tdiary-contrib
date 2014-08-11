# hide_sidebar_iphone.rb
#
# Copyright (C) 2008 SHIBATA Hiroshi <shibata.hiroshi@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#

add_header_proc do
	if @conf.iphone? then
		<<-CSS
		<style type="text/css"><!--
		div.sidebar {
			display: none;
		}
		div.main {
			width: 100%;
			float: none;
		}
		--></style>
		CSS
	end
end
