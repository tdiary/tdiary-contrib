# -*- coding: utf-8 -*-
# comment_pushbullet.rb
#
# メールの代わりにPushbulletサービスを使ってツッコミを知らせる
# プラグインを有効にした上で、Access Tokenを設定する
#
# Options:
#   設定画面から指定できるもの
#     @options['comment_pushbullet.access_token']
#          自分のPushbulletアカウントのAccess Token https://www.pushbullet.com/account
#   設定画面から指定できるもの(ツッコミメールと共通)
#     @options['comment_mail.enable']
#          メールを送るかどうかを指定する。true(送る)かfalse(送らない)。
#          無指定時はfalse。
#     @options['comment_mail.header']
#          メールのSubjectに使う文字列。振り分け等に便利なように指定する。
#          実際のSubjectは「指定文字列:日付-1」のように、日付とコメント番号が
#          付く。ただし指定文字列中に、%に続く英字があった場合、それを
#          日付フォーマット指定を見なす。つまり「日付」の部分は
#          自動的に付加されなくなる(コメント番号は付加される)。
#          無指定時には空文字。
#
#   tdiary.confでのみ指定できるもの:
#
# Copyright (c) 2015 TADA Tadashi <t@tdtds.jp>
# You can distribute this file under the GPL2 or any later version.
#
def comment_pushbullet
	require 'pushbullet'

	header = (@conf['comment_mail.header'] || '').dup
	header << ":#{@conf.date_format}" unless /%[a-zA-Z%]/ =~ header
	serial = @diaries[@date.strftime('%Y%m%d')].count_comments(true)
	title = %Q|#{@date.strftime(header)}-#{serial} #{@comment.name}|
	body = @comment.body.sub( /[\r\n]+\Z/, '' )
	link = @conf.base_url + anchor(@date.strftime('%Y%m%d')) + '#c' + "%02d"%serial

	Pushbullet.api_token = @conf['comment_pushbullet.access_token']
	Pushbullet::Contact.me.push_link(title,link,body)
end

add_update_proc do
	comment_pushbullet if @mode == 'comment'
end

add_conf_proc( 'comment_mail', comment_mail_conf_label, 'tsukkomi' ) do
	comment_mail_basic_setting
	comment_mail_basic_html
end

add_conf_proc( 'comment_pushbullet', 'Pushbullet', 'tsukkomi' ) do
	if @mode == 'saveconf' then
		@conf['comment_pushbullet.access_token'], = @cgi.params['comment_pushbullet.access_token']
	end

	<<-HTML
	<h3 class="subtitle">Pushbullet Access Token</h3>
	<p>Access Token (see <a href="https://www.pushbullet.com/account">https://www.pushbullet.com/account</a>)</p>
	<p><input name="comment_pushbullet.access_token" value="#{h @conf['comment_pushbullet.access_token']}" size="50"></p>
	HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
