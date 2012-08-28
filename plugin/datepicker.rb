# -*- coding: utf-8 -*-
#
# datepickr.rb - show jQuery UI datepicker
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
      
      jquery_ui = ''
      
      if @conf.lang == 'ja'
          jquery_ui << %Q|<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1/i18n/jquery.ui.datepicker-ja.min.js"></script>|
      end
      
      jquery_ui
      
   else
      ''
      
   end

end

if /\A(?:form|preview|append|edit|update)\z/ =~ @mode
   enable_js('datepicker.js')
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
