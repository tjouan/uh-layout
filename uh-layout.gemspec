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

  s.files       = `git ls-files lib`.split $/
  s.extra_rdoc_files = %w[README.md]


  s.add_development_dependency 'uh',    '~> 2.0'
  s.add_development_dependency 'uh-wm', '~> 0.0', '>= 0.0.9'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.2'
end
