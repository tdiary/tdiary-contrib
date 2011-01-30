# -*- coding: utf-8 -*-
# Copyright (C) 2011, KADO Masanori <kdmsnr@gmail.com>
# You can redistribute it and/or modify it under GPL.
if @mode == 'day'
	add_body_leave_proc do
		@conf['zenback.script'] || ''
	end
end

add_conf_proc( 'zenback', 'zenback', 'etc' ) do
	if @mode == 'saveconf' then
		@conf['zenback.script'] = @cgi.params['zenback.script'][0]
	end

<<-HTML
   <h3>Script Code</h3>
   <p><input size="88" name="zenback.script" value="#{@conf['zenback.script']}"></p>
HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3

