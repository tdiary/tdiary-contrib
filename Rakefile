require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

task :default => [:spec]

desc 'Run the code in spec'
RSpec::Core::RakeTask.new(:spec) do |t|
	t.pattern = "spec/**/*_spec.rb"
end
