require File.expand_path('../lib/uh/layout/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'uh-layout'
  s.version     = Uh::Layout::VERSION.dup
  s.summary     = 'simple tiling and stacking layout for uh-wm'
  s.description = s.name
  s.license     = 'BSD-3-Clause'
  s.homepage    = 'https://rubygems.org/gems/uh-layout'

  s.authors     = 'Thibault Jouan'
  s.email       = 'tj@a13.fr'

  s.files       = `git ls-files`.split $/


  s.add_development_dependency 'uh',    '~> 1.0'
  s.add_development_dependency 'rake',  '~> 10.4'
  s.add_development_dependency 'rspec', '~> 3.2'
end
