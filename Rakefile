# Rakefile for building tdiary-conrib package
require 'rake/packagetask'

package = {
  :name         => 'tdiary-contrib',
  :root         => File.expand_path(File.dirname(__FILE__)),
  :include_dirs => %w[doc filter lib misc plugin spec test util].map{|d| File.join(d, '**', '*') },
  :binary_ext   => %w[swf].map{|ext| ".#{ext}" },
}
package[:pkgdir] = File.join(package[:root], 'package')
package[:rev]    = 'r' << `svnversion --no-newline --committed #{package[:root]}`[/\d+[MS]{0,2}$/]
package.freeze

desc 'update source and packaging'
task :default => [:update, :package, :clean]

desc "Run all specs"
task :spec do
	require 'rake'
	require 'spec/rake/spectask'
	Spec::Rake::SpecTask.new do |t|
		t.spec_files = FileList['spec/**/*_spec.rb']
		t.spec_opts = ['--options', 'spec/spec.opts']
	end
end

desc "Run all tests"
task :test do
	require 'test/unit'
	test_files = FileList['test/**/*_test.rb']
   test_files.each do |t|
		sh "ruby #{t}"
   end
end

desc 'Update files from Subversion Repository'
task :update do |t|
  sh 'svn', 'update', package[:root]
end

pkg = Rake::PackageTask.new(package[:name], package[:rev]) do |p|
  p.package_dir = package[:pkgdir]
  p.package_files.include(package[:include_dirs])
  p.need_tar_gz  = true
  p.need_tar_bz2 = false
end

desc 'convert source encoding from UTF-8 to EUC-JP'
task :to_euc => pkg.package_dir_path
file pkg.package_dir_path do |t|
  t.prerequisites.each do |f|
    filename = File.join(pkg.package_dir_path, f)
    # exclude directories and binary files
    next if File.ftype(filename) != 'file' ||
            package[:binary_ext].include?(File.extname(filename))
    sh "nkf -O --euc #{filename} #{filename}.tmp && " <<
       "touch -m -r #{filename} #{filename}.tmp && " <<
       "mv #{filename}.tmp #{filename}"
    # use iconv instead of nkf in the following another way...
    # sh "iconv --from-code=utf-8 --to-code=eucjp-ms --output #{filename}{.tmp,} && " <<
    #    "touch -m -r #{filename}{,.tmp} && " <<
    #    "mv #{filename}{.tmp,}"
  end
  touch t.name
end

desc 'clean package files'
task :clean do
  rm_rf File.join(package[:pkgdir], "#{package[:name]}-#{package[:rev]}")
end
