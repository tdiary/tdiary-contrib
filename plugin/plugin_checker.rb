# plugin_checker.rb
#
# Copyright (c) 2012 MATSUOKA Kohei <kmachu@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#

def plugin_checker_js_settings
	enable_js('plugin_checker.js')
	add_js_setting('$tDiary.plugins', plugins.to_json)
	add_js_setting('$tDiary.mode', @mode.to_json)
end

if /\A(form|edit|preview|showcomment)\z/ === @mode
  add_header_proc do
    <<-STYLE
    <style>
    div.plugin_checker {
      font-size: small;
      margin: 0.5em;
      padding: 0.5em;
      border: solid 1px #999;
	    border-radius: 5px;
	    -moz-box-shadow:0 1px 3px rgba(0,0,0,0.25),0 -1px 0 rgba(0,0,0,0.1) inset;
	    -webkit-box-shadow:0 1px 3px rgba(0,0,0,0.25),0 -1px 0 rgba(0,0,0,0.1) inset;
	    box-shadow:0 1px 3px rgba(0,0,0,0.25),0 -1px 0 rgba(0,0,0,0.1) inset;
      background: #feffff; /* Old browsers */
      background: -moz-linear-gradient(top,  #feffff 0%, #fbfcd4 100%); /* FF3.6+ */
      background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#feffff), color-stop(100%,#fbfcd4)); /* Chrome,Safari4+ */
      background: -webkit-linear-gradient(top,  #feffff 0%,#fbfcd4 100%); /* Chrome10+,Safari5.1+ */
      background: -o-linear-gradient(top,  #feffff 0%,#fbfcd4 100%); /* Opera 11.10+ */
      background: -ms-linear-gradient(top,  #feffff 0%,#fbfcd4 100%); /* IE10+ */
      background: linear-gradient(to bottom,  #feffff 0%,#fbfcd4 100%); /* W3C */
    }
    div.plugin_checker ul {
      margin: 1em;
    }
    </style>
    STYLE
  end
  plugin_checker_js_settings
end
