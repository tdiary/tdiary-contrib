# -*- coding: utf-8 -*-
# Copyright (C) 2011, KADO Masanori <kdmsnr@gmail.com>
# You can redistribute it and/or modify it under GPL.
def insert_zenback
	return if feed?
	@conf['zenback.script'] || ''
end

if @mode == 'day' and (respond_to?(:section_mode?) ? section_mode? : true)
	if defined? add_comment_leave_proc
		add_comment_leave_proc do
			insert_zenback
		end
	else
		add_body_leave_proc do
			insert_zenback
		end
	end
end

add_conf_proc( 'zenback', 'zenback', 'etc' ) do
	if @mode == 'saveconf' then
		@conf['zenback.script'] = @cgi.params['zenback.script'][0]
	end

<<-HTML
   <h3>Script Code</h3>
   <p><input size="88" name="zenback.script" value="#{h @conf['zenback.script']}"></p>
HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
