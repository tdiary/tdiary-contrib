# -*- coding: utf-8 -*-
# steam.rb $Revision: 1.0 $
#
# 概要:
# steam(store.steampowered.com)のゲームのウィジェットを
# 貼るプラグインです。
#
# 使い方:
# steamの任意のゲームのID(store.steampowered.com/app/{id})
# を指定することにより、ウィジェットが貼り付けられます。
#
# Copyright (c) 2016 kp <kp@mmho.net>
# Distributed under the GPL
#

=begin ChangeLog
=end

def steam( id )
   <<-HTML
   <div class="steam-wrapper">
      <div class="steam-container">
         <iframe src="//store.steampowered.com/widget/#{id}/" frameborder="0" width="646" height="190"></iframe>
      </div>
   </div>
   HTML
end

add_header_proc do
   if @mode !~ /conf$/ and not bot? then
      <<-HTML
         <style type="text/css"><!--
            div.steam-container{
               position: relative;
               padding-bottom:30%;
               padding-top:100px;
               height:0px;
               overflow:hidden;
            }
            div.steam-container iframe{
               position:absolute;
               top:0;
               left:0;
               width:100%;
               height:100%;
            }

            div.steam-wrapper{
               width:650px;
               max-width:100%;
         --></style>
      HTML
   end
end
