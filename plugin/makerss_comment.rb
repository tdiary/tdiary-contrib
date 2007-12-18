#
# makerss_comment.rb: extension for makerss plugin.
#
# Copyright (C) 2007 by SHIBATA Hiroshi <h-sbt@nifty.com>
# Distributed under GPL2.
#

class MakeRssComments < MakeRssFull
	def title
		'(comments only)'
	end
	
	def item( seq, body, rdfsec )
		return if rdfsec.section.respond_to?( :body_to_html )
		super
	end
	
	def file
		f = @conf['makerss.no_comments.file'] || 'comments.rdf'
		f = 'comments.rdf' if f.length == 0
		f
	end
	
	def write( encoder )
		super( encoder )
	end
	
	def url
		u = @conf['makerss.no_comments.url'] || "#{@conf.base_url}comments.rdf"
		u = "#{@conf.base_url}comments.rdf" if u.length == 0
		u
	end
end

@makerss_rsses << MakeRssComments::new( @conf )
