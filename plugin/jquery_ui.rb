# -*- coding: utf-8 -*-
#
# jquery_ui.rb - use jQuery UI
#
# Copyright (C) 2012, tamoot <tamoot+tdiary@gmail.com>
# You can redistribute it and/or modify it under GPL.
#

#
# not support
# 
return if feed? || @conf.mobile_agent?

add_header_proc do
   if /\A(?:form|preview|append|edit|update)\z/ =~ @mode
      
      themes   = @conf['jquery.theme']
      if themes.nil? || theme == ''
         themes = 'base'
      end
      
      jquery_ui = ''
      jquery_ui << %Q|<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/#{themes.downcase}/jquery-ui.css"/>|
      jquery_ui << %Q|<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1/jquery-ui.min.js"></script>|
      jquery_ui
      
   else
      ''
      
   end

end

add_conf_proc( 'jquery_ui', 'jQuery UI' ) do
   if @mode == 'saveconf' then
      @conf['jquery.theme'] = @cgi.params['jquery.theme'][0]
      
   end
   
   <<-HTML
   <h3 class="subtitle">Theme name</h3>
   <p><input name="jquery.theme" value="#{h @conf['jquery.theme']}" size="40"></p>
   <p>sample) blitzer, flick .. <a href="http://jqueryui.com/themeroller/">See JQuery Theme.</a></p>
   <p>default is <b>base</b>.</p>
   HTML
   
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
