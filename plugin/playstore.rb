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

require 'date'

class PlayStore < MarketBot::Android::App
   def initialize(app_id,option={})
      super(app_id,option)
   end

   def save(path)
      File.open(path,"wb"){ |f|
         Marshal.dump(self.html,f)
      }
   end

   def load(path)
      html = nil
      File.open(path,"rb"){ |f|
         begin
            html = Marshal.restore(f)
         rescue
            html = nil
         end
      }
      unless html.nil?
         result = PlayStore.parse(html)
         update_callback(result)
      end
      return html
   end
end

def playstore_load_cache(app)
   path="#{@cache_path}/playstore/#{app.app_id}"
   begin
      stat = File::Stat.new(path)
   rescue Errno::ENOENT
      return nil
   end
   m = Date.parse(stat.mtime.to_s)
   return nil if Date.today - m > 7 # 1week before
   return app.load(path)
end

def playstore_save_cache(app)
   path="#{@cache_path}/playstore/#{app.app_id}"
   dir = File.dirname(path)
   Dir.mkdir(dir) unless File.directory?(dir)
   
   app.save(path)
end

def playstore(app_id)
   app = PlayStore.new(app_id) 
   if playstore_load_cache(app).nil?
      app.update
      save = true
   else
      save = false
   end
   if app.nil? || app.error
      html =
         <<-HTML
            <div class="market">#{app_id} was not found.</div>
         HTML
   else
      playstore_save_cache(app) if save
      html =
      <<-HTML
         <div class="market">
            <div class="leader"><a href="#{app.market_url}">#{app.title} #{app.current_version}</a>
                - <span class="dev">#{app.developer}</span></div>
            <a href="#{app.market_url}">
               <img class="icon" src="#{app.banner_icon_url}" title="#{app.title}">
            </a>
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
   app = PlayStore.new(app_id)
   if playstore_load_cache(app).nil?
      app.update
      save = true
   else
      save = false
end
   if app.nil? || app.error
      html = "<em>#{app_id} was not found</em>"
   else
      app.update
      playstore_save_cache(app) if save
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
