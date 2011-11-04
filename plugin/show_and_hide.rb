# -*- coding: utf-8 -*-
#
# show_and_hide.rb - Show or hide the elements with a sliding motion using jQuery.
#
# Copyright (C) 2011, tamoot <tamoot+tdiary@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#

require 'digest/md5'

if /\A(?:latest|day|month|nyear|preview)\z/ =~ @mode
   enable_js('show_and_hide.js')
   
end

def show_and_hide(contents, title = 'Show contents', 
                  type = :link,
                  rss_title = '(Hide contents on RSS. See my page...)')
   
   data_id = show_and_hide_id(contents)
   
   toggle_attr = {:class => 'show_and_hide_toggle',
                  :"data-showandhideid" => data_id}
   
   dom_contents = ''
   
   if feed? # RSS
      dom_contents = h(rss_title)
       
   elsif type.to_s == 'button'
      toggle_attr.merge!(:value => title, :type => "button")
      dom_contents = %Q|<input #{hash2attr(toggle_attr)}>| + 
                     show_and_hide_contents(contents, data_id)
      
   else
      toggle_attr.merge!(:href => 'javascript:void(0)')
      dom_contents = %Q|<a #{hash2attr(toggle_attr)}>#{h(title)}</a>| + 
                     show_and_hide_contents(contents, data_id)
      
   end
   
   dom_contents
   
end

def show_and_hide_id(contents)
   @@show_and_hide_counter ||= 0
   @@show_and_hide_counter  += 1
   
   "#{Time::now.strftime("%s")}_#{@@show_and_hide_counter}_#{ Digest::MD5.hexdigest(contents)}"
   
end

def show_and_hide_contents(contents, id)
   %Q|<div class="show_and_hide" id="#{id}">#{h(contents)}</div>|
   
end

def hash2attr(hash)
   attrs = []
   
   hash.keys.each do |k|
      attrs << %Q|#{k}="#{hash[k]}"|
   end
   
   attrs.join(" ")
   
end
    
# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3

