require File.expand_path('../lib/uh/layout/version', __FILE__)

Gem::Specification.new do |s|
  s.name    = 'uh-layout'
  s.version = Uh::Layout::VERSION.dup
  s.summary = 'Simple layout for uh'
  s.description = s.name
  s.homepage = 'https://rubygems.org/gems/uh-layout'

  s.authors = 'Thibault Jouan'
  s.email   = 'tj@a13.fr'

  s.files       = `git ls-files`.split $/
  s.test_files  = s.files.grep /\A(spec|features)\//
  s.executables = s.files.grep(/\Abin\//) { |f| File.basename(f) }


  s.add_development_dependency 'uh'
  s.add_development_dependency 'rake',  '~> 10.4'
  s.add_development_dependency 'rspec', '~> 3.2'
end
