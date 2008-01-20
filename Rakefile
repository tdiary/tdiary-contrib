# Rakefile for building tdiary-conrib package
require 'rake/packagetask'

package = {
  :name => 'tdiary-contrib',
  :include_dir => %w[doc filter lib misc plugin spec test util].map{|d| "#{d}/**/*" },
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

desc 'convert source encoding from UTF-8 to EUC-JP'
task :to_euc => pkg.package_dir_path
file pkg.package_dir_path do |t|
  t.prerequisites.each do |f|
    filename = "#{pkg.package_dir_path}/#{f}"
    # exclude directories and binary files
    if (File.ftype(filename) == "file" &&
        !package[:binary_ext].include?(File.extname(filename)))
      sh "nkf -e #{filename} > #{filename}.tmp && mv #{filename}.tmp #{filename}"
    end
  end
  sh "touch #{t.name}"
end
