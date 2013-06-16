require 'tdiary'
require 'tdiary/application'

module TDiary
	class Contrib
		def self.root
			File.expand_path('../..', __FILE__)
		end

		class Plugin
			def self.setup(sp_path)
				sp_path << File.join(TDiary::Contrib.root, 'plugin')
			end
		end
	end

	Application.configure do
		config.assets_paths << File.join(TDiary::Contrib.root, 'js')
	end
end
