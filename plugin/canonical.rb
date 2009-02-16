# canonical.rb

if /latest/ =~ @mode then
	add_header_proc do
		<<-HTML
		<link rel="canonical" href="#{@conf.base_url}" />
		HTML
	end
end
