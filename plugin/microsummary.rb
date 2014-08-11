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

def create_xml file_name
	xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<generator xmlns="http://www.mozilla.org/microsummaries/0.1"
           name="tDiary Entry Title">
  <template>
    <transform xmlns="http://www.w3.org/1999/XSL/Transform" version="1.0">
      <output method="text"/>
      <template match="/">
        <value-of select="html/head/title"/>
        <choose>
          <when test="boolean(descendant::div[attribute::class='body'][1]/div[attribute::class='section'][last()]/h3)">
            <text> - </text>
            <value-of select="descendant::div[attribute::class='body'][1]/div[attribute::class='section'][last()]/h3"/>
          </when>
          <when test="boolean(descendant::div[attribute::class='day'][1]/h2)">
            <text> - </text>
            <value-of select="descendant::div[attribute::class='day'][1]/h2"/>
          </when>
        </choose>
      </template>
    </transform>
  </template>
  <update interval="240"/>
  <pages>
   <include>^#{@conf.base_url.gsub(/\./, '\\.')}$</include>
  </pages>
</generator>
XML

	begin
		File::open( file_name, 'w' ) do |f|
			f.print to_utf8( xml )
		end
	rescue
	end
end

def microsummary_init
	@conf['generator.xml'] ||= ""
	create_xml( @conf['generator.xml'] ) unless File::exists? @conf['generator.xml']
end

if @mode == 'saveconf'
	def saveconf_microsummary
		@conf['generator.xml'] = @cgi.params['generator.xml'][0]
	end
end
