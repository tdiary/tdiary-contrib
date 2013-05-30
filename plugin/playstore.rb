# -*- coding: utf-8 -*-
# playstore.rb 
# 
# 概要:
#   GooglePlay( play.goog.com)へのリンクを生成します。
#
# 使い方:
#   playstore'app_id' or playstore_txt'app_id'
#
# Copyright (c) 2014 kp <knomura.1394@gmail.com>
# Distributed under the GPL
#
begin
   require 'market_bot'
rescue
   retry if require 'rubygems'
end

def playstore(app_id)

   app = MarketBot::Android::App.new(app_id)
   if app.nil?
      html =
         <<-HTML
            <div class="market">#{app_id} was not found.</div>
         HTML
   else
      app.update
      html =
      <<-HTML
         <div class="market">
            <div class="leader"><a href="#{app.market_url}">#{app.title} #{app.current_version}</a>
                - <span class="dev">#{app.developer}</span></div>
            <img class="icon" src="#{app.banner_icon_url}" title="#{app.title}">
            <ul class="info">
            <li>Rating:#{app.rating}</li>
            <li>Price:#{app.price}</li>
            </ul>
         </div>
      HTML
   end
   return html
end

def playstore_text(app_id)
   app = MarketBot::Android::App.new(app_id)
   if app.nil?
      html = "<em>#{app_id} was not found</em>"
   else
      app.update
      html=%Q[<a href="#{app.market_url}">#{app.title} #{app.current_version}</a>]
   end
   return html
end

add_header_proc do
   if @mode !~ /conf$/ and not bot? then
      <<-HTML
        <style type="text/css"><!--
         div.market ul.info {
            list-style: none;
            padding: 3px;
         }
         div.market img.icon {
            float: left;
         }
         div.market span.dev {
            font-size: small;
            color: gray;
         }
         div.market div.leader {
            background: #a4c639;
            border-top-left-radius: 6px;
            border-top-right-radius: 6px;
            padding: 3px;
         }
         div.market {
            background: #f5f5f5;
            border-radius: 6px;
            margin: 5px;
            display: block;
            overflow: hidden;
            box-shadow: 3px 3px 3px 0px lightgray;
         }
        --></style>
      HTML
   else
      ''
   end
end
# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
