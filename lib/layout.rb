class Layout
  require 'forwardable'
  require 'layout/container'
  require 'layout/screen'
  require 'layout/tag'

  include Holo

  extend Forwardable
  def_delegator :@screens, :current, :current_screen
  def_delegator :current_screen, :suggest_geo_for

  attr_reader :screens

  def screens=(screens)
    @screens = Container.new(screens.map { |id, geo| Screen.new(id, geo) })
  end

  def <<(client)
    client.geo = suggest_geo_for client.window
    client.moveresize
    client.show
    client.focus
  end

  def remove(client)
  end
end
