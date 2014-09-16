# bigpresen.rb $Revision: 1.03 $
#
# bigpresen : クリックで進行する「高橋メソッド」風巨大文字プレゼンテーションを挿入
#
#  パラメタ :
#  str : 本文。"|"はスライドの区切り、"/"はスライド内の改行となる。
#   "|"と"|"を表示する場合には、前に"\"をつけてエスケープ。
#  width : スライドの幅。ピクセルで指定。(デフォルト : 480)
#  height : スライドの高さ。ピクセルで指定。(デフォルト : 320)
#
# 日記本文に、<%= bigpresen 'str','width','height' %> の形式で記述します。
# 文字のサイズは、表示テキストとスライドのサイズに合うよう自動的に調整されます。
# JavaScriptとDHTMLを用いて動かすので、閲覧環境によっては表示されないこともあります。
#
# Copyright (c) 2006 Maripo Goda
# mailto:madin@madin.jp
# Document URL http://www.madin.jp/works/plugin.html
# You can redistribute it and/or modify it under GPL2.

@bigPresenID = 0;

def bigpresen (str='', width='480',height='320')
	scriptID = 'bp' + @bigPresenID.to_s
	@bigPresenID += 1;

	presen_ary = str.gsub("\\/",'&frasl;').gsub("\\|","&\#65073").split(/\|/);
	presen_ary.collect!{|s|
		s = '"' + s.gsub('/','<br>') + '"'
	}
	presen_str = presen_ary.join(',')

return <<HTML
<script type="text/javascript">
<!--
t#{scriptID} = 0;
w#{scriptID}=#{width};
h#{scriptID}="#{height}";
msg#{scriptID} = new Array(#{presen_str});
function #{scriptID} () {
	if (t#{scriptID} < msg#{scriptID}.length) {
		msgArr = msg#{scriptID}[t#{scriptID}].split('<br>');
		maxPx = h#{scriptID} * 0.8;
		for (t = 0; t < msgArr.length; t ++) {
			maxPx = Math.min(maxPx, w#{scriptID} * 2 * 0.9 / countLength(msgArr[t]));
		}
		maxPx = Math.min(maxPx, Math.floor(h#{scriptID} * 0.8 / msgArr.length));
	        with (document.getElementById("#{scriptID}")) {
			innerHTML = msg#{scriptID}[t#{scriptID}];
			style.fontSize = maxPx+"px";
			style.top = ((h#{scriptID}-(maxPx * msgArr.length)) / 2) + "px";
		}
		t#{scriptID} ++;
	}
	else {
		t#{scriptID} = 0;
		with (document.getElementById("#{scriptID}")) {
			innerHTML = "《REPLAY》";
			style.fontSize = '100%';
			style.top = '50%';
		}
	}
}

function countLength (str)
	{
	len = 0;
	for (i = 0; i < str.length; i++) {
		len ++;
		if (escape(str.charAt(i)).length > 3) {
			len ++
		}
	}
	return Math.max(len, 1);
}
-->
</script>

<noscript><p>JavaScript Required.</p></noscript>
<div class="bigpresen" style="text-align:center; position:relative; width:#{width}px; height:#{height}px; background:#fff;border:ridge 4px #ccc;" onclick="#{scriptID}()">

<span id="#{scriptID}" style="width:100%; position:absolute; top:50%; left:0; line-height:100%; color:black; font-family:'ＭＳ Ｐゴシック', sans-serif;">《START》</span>

</div>

HTML
end
