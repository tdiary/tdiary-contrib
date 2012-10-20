# Source code embedded plugin for tDiary.
# Copyright (C) 2012 Koichiro Ohba <koichiro@meadowy.org>
# License under MIT.

add_header_proc do
  <<-EOS
<link href="js/prettify/prettify.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="js/prettify/prettify.js"></script>
<script type="text/javascript"><!--
jQuery.event.add(window, "load", function(){
  prettyPrint();
});
//-->
</script>
EOS
end

def code(content, lang = nil)
  <<-EOS
<pre class="prettyprint#{lang ? ' lang-' + lang : ''}">
#{content}</pre>
EOS
end
