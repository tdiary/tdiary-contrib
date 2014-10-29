# -*- coding: utf-8 -*-
#
# yo_update.rb - Japanese resource
#
# Copyright (C) 2014, zunda <zundan at gmail.com>
#
# Permission is granted for use, copying, modification,
# distribution, and distribution of modified versions of this
# work under the terms of GPL version 2 or later.
#

def yo_update_conf_label
	'更新時にYoを送る'
end

def yo_update_test_result_label(username, result)
	"- <tt>#{h username}</tt> に Yo を送りました: <tt>#{h result}</tt>"
end

def yo_update_conf_html(conf, n_subscribers, test_result)
	action_label = {
		'send_on_update' => '日記が追加された時',
		'send_on_comment' => 'ツッコミされた時',
	}
	<<-HTML
	<h3 class="subtitle">API key</h3>
	<p><input name="yo_update.api_key" value="#{h conf['yo_update.api_key']}" size="40"></p>
	<h3 class="subtitle">Username</h3>
	<p><input name="yo_update.username" value="#{h conf['yo_update.username']}" size="40"></p>
	<h3 class="subtitle">Yo を送るタイミング</h3>
	<ul>
	#{%w(send_on_update send_on_comment).map{|action|
		checked = conf["yo_update.#{action}"] ? ' checked' : ''
		%Q|<li><label for="yo_update.#{action}"><input id="yo_update.#{action}" name="yo_update.#{action}" value="t" type="checkbox"#{checked}>#{action_label[action]}</label>|
	}.join("\n\t")}
	</ul>
	<p>Yo を<input name="yo_update.test" value="" size="10">にリンク<input name="yo_update.link" value="#{yo_update_url}" size="40">(不要なら空白)をつけて送ってみる#{test_result}</p>
	<h3 class="subtitle">現在の受信者数</h3>
	<p>#{h n_subscribers}</p>
	<h3 class="subtitle">Yoボタン</h3>
	<p>ページのどこかに下記を追加してください</p>
	<pre>&lt;div id=&quot;yo-button&quot;&gt;&lt;/div&gt;</pre>
	<h3 class="subtitle">やり方</h3>
	<ol>
	<li>個人用 Yo アカウントで <a href="http://dev.justyo.co/">http://dev.justyo.co/</a> にログインする
	<li>ページ内の指示に従って APIアカウントを作成する。
		Callback URL は空白のままにしてください
	<li>API key と API username を上にコピーする
	</ol>
	HTML
end
