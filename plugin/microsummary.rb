# microsummary.rb
#
# Copyright (c) 2006 elytsllams <smallstyle@gmail.com>
# Distributed under the GPL
#

add_header_proc do
	generator_xml = @conf['generator.xml']

	if generator_xml != nil and @mode == 'latest' and !@cgi.valid?( 'date' )
		%Q|\t<link rel="microsummary" href="#{generator_xml}" type="application/x.microsummary+xml">\n|
	end
end

def microsummary_init
   @conf['generator.xml'] ||= ""
end

if @mode == 'saveconf'
   def saveconf_microsummary
		@conf['generator.xml'] = @cgi.params['generator.xml'][0]
	end
end
