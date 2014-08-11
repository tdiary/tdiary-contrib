# -*- coding: utf-8 -*-
#
# coderay.rb - easy syntax highlighting for selected languages
#  refer to the URL below.
#  http://coderay.rubychan.de/
#
# Copyright (C) 2013, tamoot <tamoot+tdiary@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#

require 'cgi'
require 'erb'
require 'coderay'

@coderay_default_css ||= ::CodeRay::Encoders[:html]::CSS.new(:default).stylesheet

def coderay(lang, text, options = {})
   html = ::CodeRay.scan(text, lang).html(:line_numbers => :inline, :bold_every => false, :line_number_anchors => false)
   %Q|<div class="CodeRay"><pre>#{html}</pre></div>|
end

add_header_proc do
   coderay_css = ''
   if @conf['coderay.css.url'] && @conf['coderay.css.url'].size > 0
      coderay_css = %Q|<link rel="stylesheet" href="#{h @conf['coderay.css.url']}" type="text/css" media="all">|
   else
      coderay_css = <<-STYLE
   <style type="text/css"><!--
   #{@coderay_default_css}
   -->
   </style>
STYLE
   end

   coderay_css
end

add_conf_proc( 'coderay', 'CodeRay' ) do
   if @mode == 'saveconf' then
      @conf['coderay.css.url'] = @cgi.params['coderay.css.url'][0]

   end

   coderay_conf = <<-HTML
   <h3 class="subtitle">custom style</h3>

   <p>The stylesheet path is used instead of CodeRay default. </p>
   <p>Path: <input name="coderay.css.url" value="#{h @conf['coderay.css.url']}" size="70"></p>
   <pre>
   sample:
   #{CGI::escape_html('<link rel="stylesheet" href="/your/tdiary/path/coderay.css" type="text/css" media="all">')}
   </pre>


   <h4>Print default stylesheet of CodeRay</h4>
   <p>1. The coderay command installed along with the CodeRay gem can print out a stylesheet for you.</p>
   <pre>
   bundle exec coderay stylesheet > /your/tdiary/path/coderay.css
   </pre>
   <p>2. Edit your stylesheet and modify permissions.</p>

   HTML

   coderay_conf

end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
