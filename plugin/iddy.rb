#
# iddy.rb: iddy.jp plugin for tDiary
#
# Copyright (C) 2007 by TADA Tadashi <sho@spc.gr.jp>
# Distributed under GPL.
#

######################################################################
# If you will modify or release another version of this code,
# please get your own application key from iddy.jp and replace below.
######################################################################
@iddy_key = 'f93d2f38442fae3a1f08e82f84d335112cca0855'

require 'open-uri'
require 'timeout'
require 'rexml/document'

def iddy( id )
	begin
		cache = "#{@cache_path}/iddy.xml"
		xml = open( cache ) {|f| f.read }
		if Time::now > File::mtime( cache ) + 60*60 then
			File::delete( cache )  # clear cache 1 hour later
		end
	rescue Errno::ENOENT
		begin
			xml = iddy_call_api( id, @iddy_key )
			open( cache, 'wb' ) {|f| f.write( xml ) }
		rescue Timeout::Error
			return '<div class="iddy error">No Profile.</div>'
		end
	end

	doc = REXML::Document::new( xml )
	if doc.elements[1].attribute( 'status' ).to_s == 'fail' then
		return '<div class="iddy error">idd.jp returns fail.</div>'
	end

	user = doc.elements.to_a( '*/*/user' )[0].elements
	profileurl = user.to_a( 'profileurl' )[0]
	unless profileurl then
		return '<div class="iddy error">No profile URL on iddy.jp.</div>'
	end

	imageurl = user.to_a( 'imageurl' )[0]
	name = user.to_a( 'name' )[0]
	nameroma = user.to_a( 'nameroma' )[0]
	mail = user.to_a( 'mail' )[0]
	submail = user.to_a( 'submail' )[0]
	
	html = '<div class="iddy">'
	html << %Q|<a href="#{profileurl.text}">|
	html << %Q|<span class="iddy-image"><img src="#{imageurl.text}" alt="image" width="96" height="96"></span>| if imageurl
	if name then
		html << %Q|<span class="iddy-name">#{name.text}</span>|
	elsif nameroma
		html << %Q|<span class="iddy-name">#{nameroma.text}</span>|
	else
		html << %Q|<span class="iddy-name">#{id}</span>|
	end
	if submail then
		html << %Q|<span class="iddy-mail">#{submail}</span>|
	elsif mail
		html << %Q|<span class="iddy-mail">#{mail}</span>|
	end
	html << '</a>'
	html << %Q|<span class="iddy-powered">Powerd by <a href="http://iddy.jp/">iddy.jp</a></span>|
	html << '</div>'
	@conf.to_native( html )
end

def iddy_call_api( id, key )
	request = "http://iddy.jp/api/user/?apikey=#{key}"
	request << "&accountname=#{id}"

	proxy = @conf['proxy']
	proxy = 'http://' + proxy if proxy
	timeout( 10 ) do
		open( request, :proxy => proxy ) {|f| f.read }
	end
end
