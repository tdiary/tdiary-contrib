#
# key.rb: Comment-key filter  Ver.0.5.0
#  included TDiary::Filter::KeyFilter class
#
# caution:
#   * This filter must use together plugin 'comment_key.rb'.
#
# see:
#   http://www20.big.or.jp/~rin_ne/soft/tdiary/commentkey.htm
#
# Copyright (c) 2005 Hahahaha <rin_ne@big.or.jp>
# Distributed under the GPL
#

module TDiary
	module Filter
		class KeyFilter < Filter
			def comment_filter( diary, comment )
				return true unless @conf['comment_key.enable']
				return true if /^(TrackBack|Pingback)$/ =~ comment.name

				require 'digest/md5'
				keyprefix = @conf['comment_key.prefix'] || 'tdiary'
				vkey = Digest::MD5.hexdigest(keyprefix + (@conf['comment_key.nodate'] == 'true' ? "" : @cgi.params['date'][0]))
				vkey == @cgi.params['comment_key'][0]
			end
		end
	end
end
