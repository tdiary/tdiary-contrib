require 'open-uri'
require 'timeout'
require 'json'

def coderwall(name, size = [60, 60])
	begin
		cache = "#{@cache_path}/coderwall.json"
		json = File.read(cache)
		File::delete(cache) if Time::now > File::mtime( cache ) + 60*60*24
	rescue Errno::ENOENT
		begin
			timeout(10) do
				json = open( "http://coderwall.com/#{name}.json" ) {|f| f.read }
			end
			open(cache, 'wb') {|f| f.write(json) }
		rescue Timeout::Error
			return ""
		end
	end

	html = '<div class="coderwall">'
	JSON.parse(json)['badges'].each do |badge|
		html << %Q|<img src="#{badge['badge']}" alt="#{badge['name']}" title="#{badge['description']}" height="#{size[0]}px" width="#{size[1]}px" />|
	end
	html << '</div>'
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
