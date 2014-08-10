# -*- coding: utf-8 -*-
# playstore.rb
#
# 概要:
#   GooglePlay(play.google.com)へのリンクを生成します。
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

   def self.valid?(app_id)
      return app_id.downcase =~ /^([a-z_]{1}[a-z0-9_]*(\.[a-z_]{1}[a-z0-9_]*)*)$/
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

def playstore_main(app_id)
   unless PlayStore.valid?(app_id)
      return :invalid
   end

   app = PlayStore.new(app_id)
   if playstore_load_cache(app).nil?
      app.update
      save = true
   else
      save = false
   end
   if app.nil? || app.error
      return :notfound
   else
      playstore_save_cache(app) if save
      return app
   end
end

def playstore(app_id)
   app = playstore_main(app_id)
   case app
   when :invalid
      <<-HTML
         <div class="playstore-frame">package name is invalid(#{app_id}).</div>
      HTML
   when :notfound
      <<-HTML
         <div class="playstore-frame">#{app_id} was not found.</div>
      HTML
   else
      <<-HTML
         <div class="playstore-frame">
            <div class="playstore-leader"><a href="#{app.market_url}">#{app.title} #{app.current_version}</a>
                - <span class="playstore-devlop">#{app.developer}</span></div>
            <a href="#{app.market_url}">
               <img class="playstore-icon" src="#{app.banner_icon_url}" title="#{app.title}" >
            </a>
            <ul class="playstore-detail">
            <li>Rating:#{app.rating}</li>
            <li>Price:#{app.price}</li>
            </ul>
         </div>
      HTML
   end
end

def playstore_text(app_id)
   app = playstore_main(app_id)
   case app
   when :invalid
      "<em>package name is invalid(#{app_id}).</em>"
   when :notfound
      "<em>#{app_id} was not found</em>"
   else
      %Q[<a href="#{app.market_url}">#{app.title}</a>]
   end
end

add_header_proc do
   if @mode !~ /conf$/ and not bot? then
      <<-HTML
        <style type="text/css"><!--
         ul.playstore-detail {
            list-style: none;
            padding: 3px;
         }
         img.playstore-icon {
            float: left;
            width:100px;
            height:100px;
            padding:6px;
         }
         span.playstore-devlop {
            font-size: small;
            color: gray;
         }
         div.playstore-leader {
            background: #a4c639;
            border-top-left-radius: 6px;
            border-top-right-radius: 6px;
            padding: 3px;
         }
         div.playstore-frame {
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
