# Copyright (C) 2011, KADO Masanori <kdmsnr@gmail.com>
# You can redistribute it and/or modify it under GPL.
require 'tdiary/tdiary_day_ext'

module TDiary
	class WikiextDiary; end

	class WikiDiary
		attr_accessor :section_no
		alias :_orig_to_html4 :to_html4
		def to_html4( opt )
			if @section_no
				idx = @section_no.to_i
				return @sections[idx - 1].html4( date, idx, opt )
			end
			_orig_to_html4 opt
		end

		alias :_orig_to_chtml :to_chtml
		def to_chtml( opt )
			if @section_no
				idx = @section_no.to_i
				return @sections[idx - 1].html4( date, idx, opt )
			end
			_orig_to_chtml opt
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
