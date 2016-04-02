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
return if feed?

if /\A(?:form|preview|append|edit|update)\z/ =~ @mode
   enable_js('//ajax.googleapis.com/ajax/libs/jqueryui/1.11.4/jquery-ui.min.js')
   if @conf.lang == 'ja'
      enable_js('//ajax.googleapis.com/ajax/libs/jqueryui/1/i18n/jquery.ui.datepicker-ja.min.js')
   end
   enable_js('datepicker.js')
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
