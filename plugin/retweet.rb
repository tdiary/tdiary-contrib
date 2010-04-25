#
# retweet.rb - show retweet count in each section
#   This plugin uses a retweet button script powered by topsy.com
#
# Copyright (C) 2010, MATSUOKA Kohei <http://www.machu.jp/diary/>
# You can redistribute it and/or modify it under GPL2.
#

#
# topsy settings. see: http://labs.topsy.com/button/retweet-button/#global_settings
#
# your twitter nickname
@topsy_nick = "your_twitter_account"
# retweet button color
@topsy_theme = "blue"
# retweet button text
@topsy_retweet_text = "ReTweet"

unless defined?(permalink)
  def permalink( date, index, escape = true )
    ymd = date.strftime( "%Y%m%d" )
    uri = @conf.index.dup
    uri[0, 0] = @conf.base_url unless %r|^https?://|i =~ uri
    uri.gsub!( %r|/\./|, '/' )
    link = uri + anchor( "#{ymd}p%02d" % index )
    link = link.sub( /#/, "%23" ) if escape
    link
  end
end

unless defined?(subtitle)
  def subtitle( date, index, escape = true )
    sn = 1
    diary = @diaries[date.strftime( '%Y%m%d' )]
    diary && diary.each_section do |section|
      if sn == index then
        old_apply_plugin = @options['apply_plugin']
        @options['apply_plugin'] = true
        title = apply_plugin( section.subtitle_to_html, true )
        @options['apply_plugin'] = old_apply_plugin
        title.gsub!( /"/, '\"' ) if escape
        return title
      end
      sn += 1
    end
  end
end

# load tospy script and initialize
add_header_proc do
	r = ''
  r << %Q|<script type="text/javascript" src="http://cdn.topsy.com/topsy.js?init=topsyWidgetCreator"></script>|
  r << %Q|<script type="text/javascript" id="topsy_global_settings">|
  r << %Q|  var topsy_theme = "#{@topsy_theme}";| if @topsy_theme
  r << %Q|  var topsy_nick = "#{@topsy_nick}";| if @topsy_nick
  r << %Q|  var topsy_retweet_text = "#{@topsy_retweet_text}"| if @topsy_retweet_text
  r << %Q|</script>|
end

# show retweet button in top of section
add_section_enter_proc do |date, index|
  <<-"EOS"
  <div class="topsy_widget_data" style="float: right; margin-left: 1em;"> <!-- {
    "url": "#{permalink(date, index)}",
    "title": "#{subtitle(date, index)}",
    "style": "big"
  } --></div>
  EOS
end

# show retweet button in end of section
add_section_leave_proc do |date, index|
  <<-"EOS"
  <div class="tags">
	  <img src="http://www.machu.jp/diary/twitter_logo_small.png" height="16" width="62" alt="Twitter">: 
    <div class="topsy_widget_data" style="float: right; margin-left: 1em;"> <!-- {
      "url": "#{permalink(date, index)}",
      "title": "#{subtitle(date, index)}",
      "style": "small"
    } --></div>
  </div>
  EOS
end
