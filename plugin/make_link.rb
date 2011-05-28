# -*- coding: utf-8 -*-
# Copyright (C) 2011, KADO Masanori <kdmsnr@gmail.com>
# You can redistribute it and/or modify it under GPL.

# needs category.rb plugin

add_edit_proc do
  <<-HTML
<div class="make-link">

Link URL: <input type="text" id="make-link-url" style="width:400px" />
<button id="make-link-button">Get Title and Link</button>

<script>
$('#make-link-button').click(function() {
  var url = $('#make-link-url')[0].value;
  var title = $.ajax({
    url: "http://query.yahooapis.com/v1/public/yql",
    type: "GET",
    dataType: "json",
    async: false,
    data: {
      q: 'select * from html where url = "' + url + '" and xpath = "//head/title"',
      format: 'xml',
    }
  }).responseXML.getElementsByTagName('title')[0].textContent;
  var link = "[[" + title + "|" + url + "]]";

  inj_c(link); // needs category.rb

  return false;
});
</script>

</div>
HTML
end
