module TDiary
	class Contrib
		def self.root
			File.expand_path('../..', __FILE__)
		end

		class Assets
			def self.setup(environment)
				environment.append_path File.join(TDiary::Contrib.root, 'js')
			end
		end
	end
end
