# development.rb - utility methods for plugin developers
#
# Copyright (c) 2011 MATSUOKA Kohei <kmachu@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#

# load standard version jquery.js instead of jquery.min.js
alias :jquery_tag_original :jquery_tag
def jquery_tag
	jquery_tag_original.gsub(/\.min/, '')
end

# js cache clear by seconds.
def script_tag_query_string
	"?#{TDIARY_VERSION}#{Time::now.strftime('%Y%m%d%H%M%S')}"
end
