# -*- coding: utf-8 -*-
# mathjax.rb $Revision: $
#
# MathJaxを使った数式表示のためのプラグイン
#
# MathJaxでTeXやMathMLを使った数式を埋め込むことができます。
#
# MathJaxについては、http://www.mathjax.org/ を参照のこと
#
# Copyright (C) 2014 by Yuh Ohmura <http://yutopia.pussycat.jp/diary/>
#
=begin ChangeLog
2017-06-05 Yuh Ohmura
    * Modity MathJax address.
2014-12-17 Yuh Ohmura
	* created.
=end
add_header_proc do
'<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    tex2jax: {
       inlineMath: [[\'$\',\'$\'], ["\\\\(","\\\\)"]],
       processEscapes: true
    }
  }
);
</script>
<script async src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=TeX-AMS_CHTML">
</script>'
end
