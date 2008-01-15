#
# comment_key.rb: Comment-key plugin  Ver.0.5.0
#
# functions:
#   * add "comment_key" key in comment form.
#
# caution:
#   * This plugin must use together filter 'key.rb'.
#
# see:
#   http://www20.big.or.jp/~rin_ne/soft/tdiary/commentkey.htm
#
# Copyright (c) 2005 Hahahaha <rin_ne@big.or.jp>
# Distributed under the GPL
#

alias :orig_comment_name_label :comment_name_label
alias :orig_comment_name_label_short :comment_name_label_short

def comment_name_label
	comment_key( orig_comment_name_label )
end

def comment_name_label_short
	comment_key( orig_comment_name_label_short )
end

def comment_key( label )
	return label unless @conf['comment_key.enable']

	require 'digest/md5'
	keyprefix = @conf['comment_key.prefix'] || 'tdiary'
	vkey = Digest::MD5.hexdigest(keyprefix + (@conf['comment_key.nodate'] == 'true' ? "" : @date.strftime( '%Y%m%d' )))
	%Q!<input type="hidden" name="comment_key" value="#{vkey}">\n! + label
end

# configuration

if TDIARY_VERSION >= '2.1.2.20050826' then
	add_conf_proc( 'comment_key', @comment_key_label_conf, 'security' ) do
		comment_key_conf
	end
else
	add_conf_proc( 'comment_key', @comment_key_label_conf ) do
		comment_key_conf
	end
end

def comment_key_conf
	if @mode == 'saveconf' then
		@conf['comment_key.enable'] = 'true' == @cgi.params['comment_key_enable'][0] ? true : false
		@conf['comment_key.prefix'] = @cgi.params['comment_key_prefix'][0]
		@conf['comment_key.nodate'] = @cgi.params['comment_key_nodate'][0]
	end
	@conf['comment_key.prefix'] = 'tdiary' unless @conf['comment_key.prefix']

	comment_key_conf_html
end
