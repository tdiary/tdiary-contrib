# Japanese resource of comment_key.rb
#
# Copyright (c) 2005 Hahahaha <rin_ne@big.or.jp>
# Distributed under the GPL
#

@comment_key_label_conf = 'コメントキーフィルタ'

def comment_key_conf_html
	<<-"HTML"
		<h3 class="subtitle">#{@comment_key_label_conf}</h3>
		<p><input type="checkbox" name="comment_key_enable" value="true" #{'checked' if @conf['comment_key.enable']}>コメントキーフィルタを有効にする</p>
		<p>コメントキーフィルタのために使用される鍵の先頭文字列を指定します。なお、この文字列はMD5にてエンコードされるため、出力HTML内に直接表現されることはありません。</p>
		<p><input name="comment_key_prefix" value="#{h( @conf['comment_key.prefix'] || 'tdiary' )}" size="40"></p>
		<p><input type="checkbox" name="comment_key_nodate" value="true" #{'checked' if @conf['comment_key.nodate']}>常に同一の鍵文字列を生成する</p>
	HTML
end
