# Show navi for twitter-bootstrap theme
#
# Copyright (c) KAOD Masanori <kdmsnr at gmail.com>
# You can redistribute it and/or modify it under GPL.

def bootstrap_navi(options = {})
  default_options = {
    :navbar_class => nil,
    :site_name? => true,
    :search_form? => true
  }
  options = default_options.merge(options)

  body = ""
  if options[:site_name?]
    body += <<-EOS
      <a class="brand" href="#{@conf.index}">#{h @conf.html_title}</a>
    EOS
  end

  body += <<-EOS
      <ul class="nav">
        #{navi_user.gsub(/span/, "li")}
        #{navi_admin.gsub(/span/, "li")}
      </ul>
  EOS

  if options[:search_form?]
    body += <<-EOS
      <form class="navbar-search pull-left"
        method="get" action="http://www.google.co.jp/search"
        onsubmit="$('#sitesearch').val($(location).attr('host')+$(location).attr('pathname'))">
        <input type="hidden" name="ie" value="UTF8">
        <input type="hidden" name="oe" value="UTF8">
        <input type="hidden" name="sitesearch" id="sitesearch">
        <input type="text" class="search-query" placeholder="Search" name="q">
      </form>
    EOS
  end

  <<-EOS
<div class="navbar #{options[:navbar_class]}">
  <div class="navbar-inner">
    <div class="container">
      #{body}
    </div>
  </div>
</div>
EOS
end

add_header_proc do
  %Q|<meta name="viewport" content="width=device-width, initial-scale=1.0">|
end
