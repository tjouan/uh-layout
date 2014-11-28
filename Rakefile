task default: :run

desc 'Execute holowm in a Xephyr X server'
task :run do
  xephyr_base = '/usr/local/bin/Xephyr :42 -ac -br -noreset'
  xephyr = if ENV.key? 'XINERAMA'
    '%s +xinerama %s %s' % [
      xephyr_base,
      '-origin 0,0 -screen 960x500',
      '-origin 960,0 -screen 960x500'
    ]
  else
    '%s -screen 1600x500' % xephyr_base
  end
  sh 'xinit ./xinitrc -- %s' % xephyr
end

desc 'Execute pry console'
task :console do
  require 'pry'
  require 'holo'
  require 'holo/wm'
  pry
end
