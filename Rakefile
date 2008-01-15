# Rakefile for building tdiary-conrib package
require 'rake/clean'

package_name = 'tdiary-contrib.tar.gz'
excludes = [".svn", "Rakefile", package_name]

CLOBBER.include(package_name)

desc 'Same for package'
task :default => :package

desc 'Make tDiary-contrib package'
task :package => [:update, package_name]

desc 'Update files from Subversion Repository'
task :update do |t|
  sh "svn update"
end

desc 'Packaged tDiary-contrib files'
file package_name => FileList["./**/*"] do |t|
  sh "tar zcf #{package_name} . " + excludes.map{|f| "--exclude #{f}"}.join(' ')
end
