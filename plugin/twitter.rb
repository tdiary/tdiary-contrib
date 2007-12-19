# twitter.rb $Revision: 1.1 $
# Copyright (C) 2007 Michitaka Ohno <elpeo@mars.dti.ne.jp>
# You can redistribute it and/or modify it under GPL2.

require 'timeout'
require 'time'
require 'open-uri'
require 'rexml/document'

@twitter_user = '' # <= Your Username.
@twitter_statuses = []

if /^(latest|day)$/ =~ @mode then
	add_header_proc do
		xml = nil
		timeout( 5 ) do
			begin
				xml = open( "http://twitter.com/statuses/user_timeline/#{@twitter_user}.xml" ){|f| f.read}
			rescue Exception
			end
		end
		doc = REXML::Document.new( xml ).root if xml
		if doc then
			doc.elements.each( 'status' ) do |e|
				@twitter_statuses << [@conf.to_native( e.elements['text'].text ), Time.parse( e.elements['created_at'].text ).localtime]
			end
		end
		''
	end
end

add_body_leave_proc do |date|
	today_statuses = []
	@twitter_statuses.each do |t, d|
		 today_statuses << [t, d] if d.to_a[3,3] == date.to_a[3,3]
	end
	if !today_statuses.empty?
		r = %Q[<div class="section">]
		r << %Q[<h3><a href="http://twitter.com/#{@twitter_user}">Twitter statuses</a></h3>]
		today_statuses.sort{|a, b| b.last<=>a.last}.each do |t, d|
			r << %Q[<p><strong>#{CGI::escapeHTML( t )}</strong> (#{d.strftime( '%H:%M:%S' )})</p>]
		end
		r << %Q[</div>]
	else
		''
	end
end
