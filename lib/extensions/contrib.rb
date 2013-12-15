# -*- coding: utf-8 -*-

module TDiary
	module Extensions
		class Contrib
			def self.sp_path
				File.join(TDiary::Contrib.root, 'plugin')
			end

			def self.assets_path
				File.join(TDiary::Contrib.root, 'js')
			end
		end
	end
end
