# -*- coding: utf-8 -*-
require 'extensions/contrib'

module TDiary
	class Contrib
		def self.root
			File.expand_path('../..', __FILE__)
		end
	end
end
