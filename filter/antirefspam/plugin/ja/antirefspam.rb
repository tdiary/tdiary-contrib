#
# antirefspam.rb 
#
# Copyright (c) 2004-2005 T.Shimomura <redbug@netlife.gr.jp>
# You can redistribute it and/or modify it under GPL2.
# Please use version 1.0.0 (not 1.0.0G) if GPL doesn't want to be forced on me.
#

@antispamref_html_antispamref = <<-TEXT
	<h3>リンク元に制限をかける</h3>
	<p>
	リファラスパムを防ぐために、refererに対して制限をかけることができます。
	</p>
	TEXT

@antispamref_html_disable = <<-TEXT
	refererに対して制限をかけない
	TEXT

@antispamref_html_myurl = <<-TEXT
	<h3>許容するリンク先の指定</h3>
	<p>
	トップページURL(#{h(if @conf.index_page.empty? then "未設定" else @conf.index_page end)})と日記のURL(#{h(if @conf.base_url.empty? then "不明" else @conf.base_url end)})以外にリンク先として許容するURLを指定します。
	正規表現も利用可能です。
	</p>
	TEXT

@antispamref_html_proxy = <<-TEXT
	<h3>HTTPプロキシーサーバーの指定</h3>
	<p>
	このプラグインは、リンク元に指定された HTTP サーバーにアクセスして、リンク元のHTML を取得します。
	このアクセスに HTTP プロキシを経由する必要がある場合は以下で設定してください。<br>
	例 : server : proxy.foo.com  port : 8080
	</p>
	TEXT

@antispamref_html_trustedurl = <<-TEXT
	<h3>信頼するリンク元の指定</h3>
	<p>
	ヒント：
	<ul>
	<li>１行に１つの URL を書いてください。</li>
	<li>\#で始まる行、空行は無視されます。</li>
	<li>"信頼するリンク元" は２段階に分けてチェックされます。</li>
	<ul>
	<li>１回目は、正規表現を使っていないものとしてチェックします。書かれた URL がリンク元に
	    含まれてさえいれば、信頼するリンク元とみなします。<br>
	    例 : リンク元が http://www.foo.com/bar/ や http://www.foo.com/baz/ の場合、
	         URL には http://www.foo.com/ と書けばよい。</li>
	<li>２回目は、正規表現を使っているものとしてチェックします。この場合、URL中 の : (コロン) と / (スラッシュ) は
	    内部でエスケープされます。正規表現を使う場合、リンク元の全体にマッチする必要がある点に注意してください。<br>
	    例 : リンク元が http://aaa.foo.com/bar/ や http://bbb.foo.com/baz/ の場合、
	         URL には http://\\w+\.foo\.com/.* と書けばよい。</li>
	</ul>
	</ul>
	</p>
	TEXT

@antispamref_html_checkreftable = <<-TEXT
	「リンク元置換リスト」にマッチするリンク元を信頼する。
	TEXT


@antispamref_html_comment = <<-TEXT
	<h3>ツッコミに制限をかける</h3>
	<p>
	コメントスパムを防ぐために、コメントに対して様々な制限をかけることができます。
	</p>
	TEXT

@antispamref_html_comment_kanaonly = <<-TEXT
	ツッコミにひらがな/カタカナが含まれていない場合は拒否する。
	TEXT

@antispamref_html_comment_maxsize = <<-TEXT
	ツッコミ文字列の長さの上限を指定（文字数）
	TEXT

@antispamref_html_comment_ngwords = <<-TEXT
	以下の単語がツッコミに含まれていた場合は拒否する<br>
	（正規表現も利用可能です。正規表現は複数行モードで動作します。
	正規表現の先頭と末尾に \/ はつけないでください）<br>
	TEXT

@antispamref_html_faq = <<-TEXT
	<h3>FAQ</h3>
	<p>
	その他、最新のFAQは <a href="http://www.netlife.gr.jp/redbug/diary/?date=20041018\#p02">http://www.netlife.gr.jp/redbug/diary/?date=20041018\#p02</a> を参照してください。
	</p>
	TEXT

