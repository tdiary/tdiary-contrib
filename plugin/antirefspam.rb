#
# antirefspam.rb 
#
# Copyright (c) 2004-2005 T.Shimomura <redbug@netlife.gr.jp>
# You can redistribute it and/or modify it under GPL2.
# Please use version 1.0.0 (not 1.0.0G) if GPL doesn't want to be forced on me.
#

add_conf_proc( 'antirefspam', 'Anti Referer Spam' ) do
	if @mode == 'saveconf'
		@conf['antirefspam.disable'] = @cgi.params['antirefspam.disable'][0]
		@conf['antirefspam.trustedurl'] = @cgi.params['antirefspam.trustedurl'][0]
		@conf['antirefspam.checkreftable'] = @cgi.params['antirefspam.checkreftable'][0]
		@conf['antirefspam.myurl'] = @cgi.params['antirefspam.myurl'][0]
		@conf['antirefspam.proxy_server'] = @cgi.params['antirefspam.proxy_server'][0]
		@conf['antirefspam.proxy_port'] = @cgi.params['antirefspam.proxy_port'][0]
		@conf['antirefspam.comment_kanaonly'] = @cgi.params['antirefspam.comment_kanaonly'][0]
		@conf['antirefspam.comment_maxsize'] = @cgi.params['antirefspam.comment_maxsize'][0]
		@conf['antirefspam.comment_ngwords'] = @cgi.params['antirefspam.comment_ngwords'][0]
	end

	<<-HTML
	#{@antispamref_html_antispamref}
	<p>
	<label for="antirefspam.disable"><input id="antirefspam.disable" type="checkbox" name="antirefspam.disable" value="true"#{" checked" if @conf['antirefspam.disable'].to_s == "true"}>#{@antispamref_html_disable}</label>
	</p>

	#{@antispamref_html_myurl}
	<p><input name="antirefspam.myurl" value="#{h @conf['antirefspam.myurl']}" size="70"></p>

	#{@antispamref_html_proxy}
	<p>
	server : <input name="antirefspam.proxy_server" value="#{h @conf['antirefspam.proxy_server']}" size="40">
	port : <input name="antirefspam.proxy_port" value="#{h @conf['antirefspam.proxy_port']}" size="5">
	</p>

	#{@antispamref_html_trustedurl}
	<textarea name="antirefspam.trustedurl" cols="70" rows="15">#{h @conf['antirefspam.trustedurl']}</textarea>

	<p>
	<label for="antirefspam.checkreftable"><input id="antirefspam.checkreftable" type="checkbox" name="antirefspam.checkreftable" value="true"#{" checked" if @conf['antirefspam.checkreftable'].to_s == "true"}>#{@antispamref_html_checkreftable}</label>
	</p>

	#{@antispamref_html_comment}
	<p>
	<label for="antirefspam.comment_kanaonly"><input id="antirefspam.comment_kanaonly" type="checkbox" name="antirefspam.comment_kanaonly" value="true"#{" checked" if @conf['antirefspam.comment_kanaonly'].to_s == "true"}>#{@antispamref_html_comment_kanaonly}</label>
	</p>
	<p>
	#{@antispamref_html_comment_maxsize} <input name="antirefspam.comment_maxsize" value="#{h @conf['antirefspam.comment_maxsize']}" size="8">
	</p>
	<p>
	#{@antispamref_html_comment_ngwords}
	<textarea name="antirefspam.comment_ngwords" cols="70" rows="15">#{h @conf['antirefspam.comment_ngwords']}</textarea>
	</p>

	#{@antispamref_html_faq}
	HTML
end

