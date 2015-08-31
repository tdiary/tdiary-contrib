# -*- coding: utf-8 -*-
#
# twitter_anywhere.rb - bringing the Twitter communication platform to tDiary
#  refer to the URL below.
#  https://dev.twitter.com/docs/anywhere/welcome
#
# Copyright (C) 2010-2012, tamoot <tamoot+tdiary@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#

def follow_button(account)
   return not_support_anywhere unless support_anywhere?
   return not_ready_anywhere   unless ready_anywhere?

   if account.nil? || account == ''
      return anywhere_plugin_error("Account name is not specified.")

   end

   <<-FOLLOW_API
   <span id="follow-twitterapi"></span>
   <script type="text/javascript">
      twttr.anywhere(function (T) {
         T('#follow-twitterapi').followButton("#{account}");
      });
   </script>
   FOLLOW_API

end

def tweet_box(label = nil, content = nil, option = {})
   return not_support_anywhere unless support_anywhere?
   return not_ready_anywhere   unless ready_anywhere?
   init_tweetbox

   @tweetbox_opt.merge!(option)
   @tweetbox_opt.merge!(:height => 120) unless option[:height].to_i > 0
   @tweetbox_opt.merge!(:width  => 480) unless option[:width].to_i > 0

   @tweetbox_opt.merge!(:label   => label)   if label
   @tweetbox_opt.merge!(:defaultContent => content) if content

   %Q|<span id="tweetbox"></span>|

end

def twitter_anywhere_settings
   enable_js('twitter_anywhere.js')
   add_js_setting('$tDiary.plugin.twitter_anywhere')

   selectors = @conf['twitter_anywhere.hovercards.selectors'].split(',').collect do |selector|
      %Q|"#{selector.strip}"|
   end
   add_js_setting('$tDiary.plugin.twitter_anywhere.selectors',
                  "[#{selectors.join(',')}]" )

   expanded = '{}'
   if @conf['twitter_anywhere.hovercards.expand_default'] == 'true'
      expanded = '{"expanded":true}'

   end
   add_js_setting('$tDiary.plugin.twitter_anywhere.hovercards')
   add_js_setting('$tDiary.plugin.twitter_anywhere.hovercards.expand_default',
                  expanded)

end


add_header_proc do

   if /\A(?:latest|day|month|nyear|preview)\z/ =~ @mode

      if ready_anywhere?
         %Q|<script src="http://platform.twitter.com/anywhere.js?id=#{h @conf['twitter_anywhere.id']}&v=1"></script>|

      else
         ''

      end

   end

end

def init_tweetbox
   @tweetbox_json_opt ||= []
   @tweetbox_opt ||= {}

end

add_footer_proc do |date|

   if /\A(?:latest|day|month|nyear|preview)\z/ =~ @mode

      if ready_anywhere?

         init_tweetbox

         @tweetbox_opt.each_pair do |k, v|
            @tweetbox_json_opt << "\"#{k}\":\"#{v}\""

         end

         tweet_box_call =  %Q|<script type="text/javascript">\n|
         tweet_box_call << %Q|<!--\n|
         tweet_box_call << %Q|   showTweetBox({#{@tweetbox_json_opt.join(',')}});\n|
         tweet_box_call << %Q|//-->\n|
         tweet_box_call << %Q|</script>\n|

      else
         ''

      end

   else
      ''

   end
end

add_conf_proc( 'twitter_anywhere', 'Twitter Anywhere' ) do
   if @mode == 'saveconf' then
      @conf['twitter_anywhere.id'] = @cgi.params['twitter_anywhere.id'][0]
      @conf['twitter_anywhere.hovercards.selectors'] = @cgi.params['twitter_anywhere.hovercards.selectors'][0]
      @conf['twitter_anywhere.hovercards.expand_default'] = @cgi.params['twitter_anywhere.hovercards.expand_default'][0]

   end

   expand_true  = ""
   expand_false = "selected"

   if @conf['twitter_anywhere.hovercards.expand_default'] == "true"
      expand_true  = "selected"
      expand_false = ""

   end

   <<-HTML
   <h3 class="subtitle">Consumer key</h3>

   <p><input name="twitter_anywhere.id" value="#{h @conf['twitter_anywhere.id']}" size="70"></p>
   <p>Register your tDiary and get Consumer key.
   <a href="http://dev.twitter.com/anywhere">Go Twitter OAuth settings.</a></p>

   <h3 class="subtitle">Rending Hovercards</h3>

   <h4>CSS Selector To limit the scope of where Hovercards appear</h4>
   <p><input name="twitter_anywhere.hovercards.selectors" value="#{h @conf['twitter_anywhere.hovercards.selectors']}" size="70"></p>
   <p>example) div.section p, div.commentshort p, div.commentbody p</p>

   <h4>Expanded by Default</h4>
   <p><select name="twitter_anywhere.hovercards.expand_default">
   <option value="true"  #{expand_true}>true</option>
   <option value="false" #{expand_false}>false</option>
   </select></p>
   HTML

end

def support_anywhere?
   return !feed?
end

def ready_anywhere?
   if @conf['twitter_anywhere.id'] && @conf['twitter_anywhere.id'].size > 0
      return true

   end

   return false

end


def not_support_anywhere
   '[Twitter@Anywhere] not support this environment.'

end

def not_ready_anywhere
   anywhere_plugin_error(
      "Twitter consumer Key not specified.",
      %Q|<a href="http://dev.twitter.com/anywhere">Go Twitter OAuth settings.</a>|)

end

def anywhere_plugin_error(message, detail= '')
   <<-PLUGIN_ERROR
   <div class="plugin-message" style="background: #FDC; border: 2px solid #d00; color: #500; padding: .1em; margin: 1em 0;">
   <p style="font-weight: bold;">[ERROR] twitter_anywhere.rb: #{message}</p><br>
   <p>#{detail}</p>
   </div>
   PLUGIN_ERROR

end

if /\A(?:latest|day|month|nyear|preview)\z/ =~ @mode
   twitter_anywhere_settings
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
