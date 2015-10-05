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
      begin
         app.update
      rescue
         return :notfound
      end
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
         <div class="playstore-frame"><a href="https://play.google.com/store/apps/details?id=#{app_id}">#{app_id}</a> was not found.</div>
      HTML
   else
      <<-HTML
         <div class="playstore-frame">
            <a href="#{app.market_url}">
               <img class="playstore-icon" src="#{app.banner_icon_url}" title="#{app.title}" >
            </a>
            <ul class="playstore-detail">
            <li><a href="#{app.market_url}">#{app.title}</a></li>
            <li>カテゴリ:#{app.category}</li>
            <li>価格:#{app.price.eql?("0")?"無料":app.price}</li>
            <li><a href="#{app.market_url}">GooglePlayで詳細をみる</a></li>
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
            display:inline-block;
            vertical-align:top;
            list-style: none;
            padding: 0px;
            margin:0px;
         }
         img.playstore-icon {
            display:inline-block;
            width:100px;
            height:100px;
         }
         div.playstore-frame {
            display: block;
            padding: 3px;
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
