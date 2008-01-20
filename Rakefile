# Rakefile for building tdiary-conrib package
require 'rake/packagetask'

package = {
  :name => 'tdiary-contrib',
  :include_dir => %w[doc filter lib misc pkg plugin spec test util].map{|d| "#{d}/**/*" },
  :binary_ext => %w[.swf]
}

desc 'update source and packaging'
task :default => [:update, :package]

desc 'Update files from Subversion Repository'
task :update do |t|
  sh "svn update"
end

pkg = Rake::PackageTask.new(package[:name], :noversion) do |p|
  p.package_dir = "./package"
  p.package_files.include(package[:include_dir])
  p.need_tar_gz = true
end
