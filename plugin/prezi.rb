#
# prezi.rb: plugin embedding presentation on prezi.com
#
# Copyright (C) 2010 TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2.
#

def prezi( prezi_id, label = 'Link to presentation', size = [512,384] )
	%Q|<object class="prezi" id="prezi_#{prezi_id}" name="prezi_#{prezi_id}" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="#{size[0]}" height="#{size[1]}"><param name="movie" value="http://prezi.com/bin/preziloader.swf"><param name="allowfullscreen" value="true"><param name="allowscriptaccess" value="always"><param name="bgcolor" value="#ffffff"><param name="flashvars" value="prezi_id=#{prezi_id}&amp;lock_to_path=1&amp;color=ffffff&amp;autoplay=no"><embed id="preziEmbed_#{prezi_id}" name="preziEmbed_#{prezi_id}" src="http://prezi.com/bin/preziloader.swf" type="application/x-shockwave-flash" allowfullscreen="true" allowscriptaccess="always" width="#{size[0]}" height="#{size[1]}" bgcolor="#ffffff" flashvars="prezi_id=#{prezi_id}&amp;lock_to_path=1&amp;color=ffffff&amp;autoplay=no"></embed></object><div class="prezi"><a href="http://prezi.com/#{prezi_id}/">#{label}</div>|
end
