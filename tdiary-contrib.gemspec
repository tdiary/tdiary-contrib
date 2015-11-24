# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tdiary/contrib/version'

Gem::Specification.new do |spec|
  spec.name          = "tdiary-contrib"
  spec.version       = TDiary::Contrib::VERSION
  spec.authors       = ["tDiary contributors"]
  spec.email         = ["support@tdiary.org"]
  spec.summary       = %q{tDiary contributions package}
  spec.description   = %q{tDiary contributions package that includes plugins, styles, utilities, libraries, filters, and extended io.}
  spec.homepage      = "http://www.tdiary.org/"
  spec.license       = "GPL-2 and/or others"

  spec.files         = Dir[
    'README.md',
    'README.en.md',
    'Rakefile',
    'doc/**/*',
    'filter/**/*',
    'io/**/*',
    'js/**/*',
    'lib/**/*',
    'misc/**/*',
    'plugin/**/*',
    'spec/**/*',
    'style/**/*',
    'util/**/*'
  ]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'tdiary'
  spec.add_dependency 'ruby-pushbullet'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "pry"
end
