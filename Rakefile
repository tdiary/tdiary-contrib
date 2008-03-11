# Rakefile for building tdiary-conrib package
require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'rake/testtask'
require 'spec/rake/spectask'

package = {
	:name         => 'tdiary-contrib',
	:root         => File.expand_path(File.dirname(__FILE__)),
	:include_dirs => %w[doc filter lib misc plugin spec test util].map{|d| File.join d, '**', '*' },
	:binary_ext   => %w[swf].map{|ext| ".#{ext}" },
}
package[:pkgdir] = File.join package[:root], 'package'
package[:rev]    = 'r' << `svnversion --no-newline --committed #{package[:root]}`[/\d+[MS]{0,2}$/]
package.freeze

Rake::TestTask.new do |t|
	t.libs << File.join(package[:root], 'plugin')
	t.pattern = File.join 'test', '**', '*_test.rb'
end

Spec::Rake::SpecTask.new(:spec) do |t|
	t.spec_opts << '--colour'
	t.spec_opts << '--options' << File.join('spec', 'spec.opts')
end

namespace :spec do
	desc "Run all specs with RCov"
	Spec::Rake::SpecTask.new(:rcov) do |t|
		t.spec_opts << '--colour'
		t.spec_opts << '--options' << File.join('spec', 'spec.opts')
		t.rcov = true
		t.rcov_opts = lambda do
			IO.readlines(File.join('spec', 'rcov.opts')).map {|l| l.chomp.split " "}.flatten
		end
	end

	namespace :rcov do
		task :clean do
			rm_rf "coverage"
		end
	end
end

desc 'Update source and packaging'
task :default => [:update, :package, :clean]

desc 'Update files from Subversion Repository'
task :update do |t|
	sh 'svn', 'update', package[:root]
end

pkg = Rake::PackageTask.new(package[:name], package[:rev]) do |p|
	p.package_dir = package[:pkgdir]
	p.package_files.include package[:include_dirs]
	p.need_tar_gz  = true
	#p.need_tar_bz2 = true
end

desc 'Convert source encoding from UTF-8 to EUC-JP'
task :to_euc do |t|
	require 'shell'
	pkg.package_files.each do |f|
		filename = File.join pkg.package_dir_path, f
		# exclude directories and binary files
		next if File.ftype(filename) != 'file' ||
		        package[:binary_ext].include?(File.extname(filename))

		case
		when Shell.new.find_system_command('nkf')
			sh <<-EOS.gsub(/^\s+/, '')
				nkf -O --euc #{filename}{,.tmp} && \\
				touch -m --reference=#{filename} #{filename}.tmp && \\
				mv #{filename}{.tmp,}
			EOS
		when Shell.new.find_system_command('iconv')
			sh <<-EOS.gsub(/^\s+/, '')
				iconv --from-code=utf-8 --to-code=euc-jp --output #{filename}{.tmp,} && \\
				touch -m --reference=#{filename} #{filename}.tmp && \\
				mv #{filename}{.tmp,}
			EOS
		end
	end
end

