# tdiary_vote.rb $Revision: 2 $
# Copyright (C) 2006 Michitaka Ohno <elpeo@mars.dti.ne.jp>
# You can redistribute it and/or modify it under GPL2.
#
# ref. http://elpeo.jp/diary/20060622.html#p01
#
# .tdiary-vote {
#   float: left;
#   background-color: aqua;
# }

require 'digest/md5'
require 'pstore'

@tdiary_vote_db = "#{@cache_path}/tdiary_vote"
@tdiary_vote_label = "投票"
@tdiary_vote_date = nil

def vote( *items )
	return '' unless @tdiary_vote_date
	h, voted	 = get_vote( @tdiary_vote_date, @cgi.cookies['tdiary_vote'][0] )
	max = h.empty? ? 1 : h.values.max
	r = %Q[<table border="1">]
	items.sort{|a, b| h[b] <=> h[a]}.each do |item|
		num = h[item]
		r << %Q[<tr>]
		r << %Q[<td>#{CGI.escapeHTML( item )}</td>]
		r << %Q[<td><span class="tdiary-vote" style="height: 2.5ex; width: #{(100*num/max).to_i}px"></span>#{num}</td>]
		unless voted then
			r << %Q[<td>]
			r << %Q[<form submit="#{@conf.index}" method="POST" style="margin: 0px; padding: 0px">]
			r << %Q[#{csrf_protection}]
			r << %Q[<input type="hidden" name="date" value="#{@tdiary_vote_date.strftime( "%Y%m%d" )}">]
			r << %Q[<input type="hidden" name="name" value="">]
			r << %Q[<input type="hidden" name="body" value="">]
			r << %Q[<input type="hidden" name="vote" value="#{CGI.escapeHTML( item )}">]
			r << %Q[<input type="submit" name="comment" value="#{@tdiary_vote_label}">]
			r << %Q[</form>]
			r << %Q[</td>]
		end
		r << %Q[</tr>]
	end
	r << %Q[</table>]
end

def get_vote( date, uid )
	h = Hash.new(0)
	voted = false
	file = "#{@tdiary_vote_db}/#{date.strftime( "%Y%m%d" )}.db"
	if File.exist?( file ) then
		PStore.new( file ).transaction do |db|
			h.update( db['vote'] ) if db.root?( 'vote' )
			voted = db['voter'].include?( uid ) if db.root?( 'voter' )
			db.abort
		end
	end
	[h, voted]
end

def add_vote( date, item, uid )
	Dir::mkdir( @tdiary_vote_db ) unless File::directory?( @tdiary_vote_db )
	file = "#{@tdiary_vote_db}/#{date.strftime( "%Y%m%d" )}.db"
	PStore.new( file ).transaction do |db|
		db['voter'] = Hash.new unless db.root?( 'voter' )
		db.abort if db['voter'].include?( uid )
		db['voter'][uid] = @cgi.remote_addr
		db['vote'] = Hash.new(0) unless db.root?( 'vote' )
		db['vote'][item] += 1
	end
end

add_body_enter_proc do |date|
	@tdiary_vote_date = date
	''
end

add_body_leave_proc do |date|
	@tdiary_vote_date = nil
	''
end

unless bot? then
	if @mode == 'comment' && @cgi.valid?( 'vote' ) && @cgi.cookies['tdiary_vote'][0] then
		add_vote( @date, @cgi.params['vote'][0], @cgi.cookies['tdiary_vote'][0] )
	end

	add_footer_proc do
		uid = @cgi.cookies['tdiary_vote'][0] || Digest::MD5.hexdigest( @cgi.remote_addr + Time.now.to_s + rand.to_s )
		cookie_path = File::dirname( @cgi.script_name )
		cookie_path += '/' if cookie_path !~ /\/$/
		cookie = CGI::Cookie::new(
			'name' => 'tdiary_vote',
			'value' => uid,
			'path' => cookie_path,
			'expires' => Time.now.gmtime + 30*24*60*60
		)
		add_cookie( cookie )
		''
	end
end
