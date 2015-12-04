# Source code embedded plugin for tDiary.
# Copyright (C) 2012 Koichiro Ohba <koichiro@meadowy.org>
# License under MIT.

add_header_proc do
  <<-EOS
<script src="https://cdn.rawgit.com/google/code-prettify/master/loader/run_prettify.js"></script>
EOS
end

def code(content, lang = nil)
  <<-EOS
<pre class="prettyprint#{lang ? ' lang-' + lang : ''}">
#{content}</pre>
EOS
end
