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
      charset: 'utf-8'
    }
  }).responseXML.getElementsByTagName('title')[0].textContent
    .replace(/\\n/g, ''); // FIXME: need to convert to UTF-8

  var link = "[[" + title + "|" + url + "]]";

  if (typeof(inj_c) == 'function') {
    inj_c(link); // old category.rb
  } else {
    $('#body').insertAtCaret(link);
  }

  return false;
});
</script>

</div>
HTML
end
