# show code snippet via gist.github.com
#
# usage:
#   gist(gist_id)
#     - gist_id: The id of the code snippet on gitst.github.com (e.g. 2056 for http://gist.github.com/2056)
#
# Copyright (c) KAKUTANI Shintaro <http://kakutani.com/>
# Distributed under the GPL

def gist( gist_id )
	gist_snippet_url = "http://gist.github.com/#{gist_id}"
	return (<<-EOS).chomp
<div class="gist_plugin"><script src="#{gist_snippet_url}.js"></script>
<noscript><a href="#{gist_snippet_url}">gist:#{gist_id}</a></noscript></div>
	EOS
end
