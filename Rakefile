# Rakefile for building tdiary-conrib package
require 'rake/packagetask'

package = {
  :name => 'tdiary-contrib',
  :root => File.expand_path(File.dirname(__FILE__)),
  :include_dirs => %w[doc filter lib misc plugin spec test util].map{|d| File.join(d, '**', '*') },
  :binary_ext => %w[.swf]
}
package[:pkgdir] = File.join(package[:root], 'package')
package[:revision] = 'r' << `svnversion --no-newline --committed #{package[:root]}`[/\d+\w?$/]
package.freeze

desc 'update source and packaging'
task :default => [:update, :package, :clean]

desc 'Update files from Subversion Repository'
task :update do |t|
  sh "svn update #{package[:root]}"
end

pkg = Rake::PackageTask.new(package[:name], package[:revision]) do |p|
  p.package_dir = package[:pkgdir]
  p.package_files.include(package[:include_dirs])
  p.need_tar_gz = true
end

desc 'convert source encoding from UTF-8 to EUC-JP'
task :to_euc => pkg.package_dir_path
file pkg.package_dir_path do |t|
  t.prerequisites.each do |f|
    filename = File.join(pkg.package_dir_path, f)
    # exclude directories and binary files
    if (File.ftype(filename) == 'file' &&
        !package[:binary_ext].include?(File.extname(filename)))
      sh "nkf -e -O #{filename} #{filename}.tmp && mv #{filename}.tmp #{filename}"
      # sh "iconv --from-code=utf-8 --to-code=euc-jp --output #{filename}{.tmp,} && mv #{filename}{.tmp,}"
    end
  end
  sh "touch #{t.name}"
end

desc 'clean'
task :clean do
  rm_rf File.join(package[:pkgdir], "#{package[:name]}-#{package[:revision]}")
end

