#
# aboutme.rb: aboutme.jp plugin for tDiary
#
# Copyright (C) 2008 MATSUI Shinsuke <poppen@karashi.org>
# You can redistribute it and/or modify it under GPL2.
#
# Acknowledgements:
#  * Based on iddy.rb by TADA.

require 'open-uri'
require 'timeout'
require 'rexml/document'

def aboutme( id )
	begin
		cache = "#{@cache_path}/aboutme.xml"
		xml = open( cache ) {|f| f.read }
		if Time::now > File::mtime( cache ) + 60*60 then
			File::delete( cache )  # clear cache 1 hour later
		end
	rescue Errno::ENOENT
		begin
			xml = aboutme_call_api( id )
			open( cache, 'wb' ) {|f| f.write( xml ) }
		rescue Timeout::Error
			return '<div class="aboutme error">No Profile.</div>'
		end
	end

	doc = REXML::Document::new( xml )
	case doc.elements['/response/status/code'].text.to_i
	when 400, 403, 503
		return '<div class="aboutme error">aboutme.jp returns fail.</div>'
	when 404
		return '<div class="aboutme error">No profile URL on aboutme.jp.</div>'
	end

	user = doc.elements.to_a( '*/*/user' )[0].elements
	profileurl = user.to_a( 'url' )[0]
	imageurl = user.to_a( 'images/large' )[0]
	nickname = user.to_a( 'nickname' )[0]

	html = '<div class="aboutme">'
	html << %Q|<a href="#{profileurl.text}">|
	html << %Q|<span class="aboutme-image"><img src="#{imageurl.text}" alt="image" width="96" height="96"></span>| if imageurl
	html << %Q|<span class="aboutme-name">#{nickname.text}</span>|
	html << '</a>'
	html << %Q|<span class="aboutme-powered">|
	html << %Q|<a href="http://aboutme.jp/" title="アバウトミー - 自分発見プロフィール" target="_blank">powerd by アバウトミー：@nifty</a>|
	html << '</span>'
	html << '</div>'
	@conf.to_native( html )
end

def aboutme_call_api( id )
	request = "http://api.aboutme.jp/api/v1/users/show/#{id}"

	proxy = @conf['proxy']
	proxy = 'http://' + proxy if proxy
	timeout( 10 ) do
		open( request, :proxy => proxy ) {|f| f.read }
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vi: ts=3 sw=3
