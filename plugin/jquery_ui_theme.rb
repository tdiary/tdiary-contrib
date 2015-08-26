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
return if feed?

add_header_proc do
   if /\A(?:form|preview|append|edit|update)\z/ =~ @mode

      themes   = @conf['jquery_ui.theme']
      if themes.nil? || theme == ''
         themes = 'base'
      end

      jquery_ui = ''
      jquery_ui << %Q|<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/#{themes.downcase}/jquery-ui.css"/>\n|
      jquery_ui

   else
      ''

   end

end

add_conf_proc( 'jquery_ui_theme', 'jQuery UI Theme' ) do
   if @mode == 'saveconf' then
      @conf['jquery_ui.theme'] = @cgi.params['jquery_ui.theme'][0]

   end

   <<-HTML
   <h3 class="subtitle">Theme name</h3>
   <p><input name="jquery_ui.theme" value="#{h @conf['jquery_ui.theme']}" size="40"></p>
   <p>sample) blitzer, flick .. <a href="http://jqueryui.com/themeroller/">See JQuery UI Theme.</a></p>
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
