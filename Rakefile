require 'rspec/core/rake_task'

task default: :spec

RSpec::Core::RakeTask.new(:spec)

desc 'Execute holowm in a Xephyr X server'
task :run do
  xephyr_base = '/usr/local/bin/Xephyr :42 -ac -br -noreset'
  xephyr = if ENV.key? 'XINERAMA'
    '%s +xinerama %s %s' % [
      xephyr_base,
      '-origin 0,0 -screen 1024x400',
      '-origin 1024,0 -screen 896x400'
    ]
  else
    '%s -screen 1920x400' % xephyr_base
  end
  sh 'xinit ./xinitrc -- %s' % xephyr
end

desc 'Execute pry console'
task :console do
  require 'pry'
  require 'holo'
  require 'holo/wm'
  require_relative 'lib/layout'
  include Holo
  pry
end
