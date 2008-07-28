# show code snippet via gist.github.com
#
# usage:
#   flickr(gist_id)
#     - gist_id: The id of the code snippet on gitst.github.com (e.g. 2056 for http://gist.github.com/2056)
#
# Copyright (c) KAKUTANI Shintaro <http://kakutani.com/>
# Distributed under the GPL

def gist( gist_id )
	%Q|<script src="http://gist.github.com/#{gist_id}.js"></script>|
end
