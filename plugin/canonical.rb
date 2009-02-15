# canonical.rb

add_header_proc do
	<<-HTML
	<link rel="canonical" href="#{@conf.base_url}"/>
	HTML
end
