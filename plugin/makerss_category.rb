#
# makerss_category.rb: extension for makerss plugin.
#
# Copyright (C) 2007 by SHIBATA Hiroshi <h-sbt@nifty.com>
# Distributed under GPL2.
#
# Usage:
#    @conf['makerss.category'] = ["mixi", "sns"]
#

class MakeRssCategory < MakeRssFull
	def title
		'(category only)'
	end
	
	def item( seq, body, rdfsec )
		return unless rdfsec.section.respond_to?( :body_to_html )
		return if rdfsec.section.categories.length == 0
		rdfsec.section.categories.each do |category|
			if @conf['makerss.category'].include?(category)
				super
			end
		end
	end
	
	def file
		f = @conf['makerss.category.file'] || 'category.rdf'
		f = 'category.rdf' if f.length == 0
		f
	end
	
	def write( encoder )
		super( encoder )
	end
	
	def url
		u = @conf['makerss.category.url'] || "#{@conf.base_url}category.rdf"
		u = "#{@conf.base_url}category.rdf" if u.length == 0
		u
	end
end

@makerss_rsses << MakeRssCategory::new( @conf )
