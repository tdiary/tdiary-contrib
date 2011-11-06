require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

task :default => [:spec]

desc 'Run the code in specs'
RSpec::Core::RakeTask.new(:spec) do |t|
	t.pattern = "spec/**/*_spec.rb"
end

namespace :spec do
	if defined?(RCov)
		desc 'Run the code in specs with RCov'
		RSpec::Core::RakeTask.new(:report) do |t|
			t.pattern = "spec/**/*_spec.rb"
			t.rcov = true
			t.rcov_opts = IO.readlines(File.join('spec', 'rcov.opts')).map {|line| line.chomp.split(" ") }.flatten
		end
	else
		desc 'Run the code in specs with SimpleCov'
		task :report do
			ENV['COVERAGE'] = 'simplecov'
			Rake::Task["spec"].invoke
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
