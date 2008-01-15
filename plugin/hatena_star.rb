# hatena_star.rb
# Itoshi Nikaido <dritoshi at gmail dot com>
# Distributed under the GPL

@hatena_star_options = {
	'token' => 'Token',
	'star.image' => '.hatena-star-star-image',
	'star.add' => '.hatena-star-add-button-image',
	'comment.image' => '.hatena-star-comment-button-image'
}

add_header_proc do
	hatena_star = %Q|\t<script type="text/javascript" src="http://s.hatena.ne.jp/js/HatenaStar.js"></script>\n|
	hatena_star << %Q|\t<script type="text/javascript"><!--
		Hatena.Star.SiteConfig = {
			entryNodes: {
				'div.section': {
					uri: 'h3 a',
					title: 'h3',
					container: 'h3'
				}
			}
		};\n|
		if @conf['hatena_star.token'] then
			hatena_star << %Q|\t\tHatena.Star.Token = '#{CGI::escapeHTML @conf["hatena_star.token"]}';\n|
		end
	hatena_star << %Q|\t//--></script>\n|
	hatena_star << %Q|\t<style type="text/css"><!--\n|
	@hatena_star_options.each do |o,v|
		next if o == 'token'
		hatena_star << %Q|\t\t#{v} { background-image: url(#{CGI::escapeHTML @conf["hatena_star.#{o}"]}); }\n| if @conf["hatena_star.#{o}"]
	end
	hatena_star << %Q|\t//--></style>\n|
end

add_conf_proc( 'hatena_star', 'Hatena::Star' ) do
	if( @mode == 'saveconf' ) then
		@hatena_star_options.keys.each do |o|
			@conf["hatena_star.#{o}"] = @cgi.params["hatena_star.#{o}"][0].strip
			if @conf["hatena_star.#{o}"].length == 0 then
				@conf["hatena_star.#{o}"] = nil
			end
		end
	end
	<<-HTML
	<h3>Token</h3>
	<p><input name="hatena_star.token" value="#{CGI::escapeHTML( @conf['hatena_star.token'] || '' )}" size=50></P>
	<h3>Star Image (URL)</h3>
	<p><input name="hatena_star.star.image" value="#{CGI::escapeHTML( @conf['hatena_star.star.image'] || '' )}" size=50></P>
	<h3>Add Star Image (URL)</h3>
	<p><input name="hatena_star.star.add" value="#{CGI::escapeHTML( @conf['hatena_star.star.add'] || '' )}" size=50></P>
	<h3>Comment Image (URL)</h3>
	<p><input name="hatena_star.comment.image" value="#{CGI::escapeHTML( @conf['hatena_star.comment.image'] || '' )}" size=50></P>
	HTML
end
