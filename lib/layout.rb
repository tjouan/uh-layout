class Layout
  require 'forwardable'
  require 'layout/container'
  require 'layout/col'
  require 'layout/screen'
  require 'layout/tag'

  include Holo

  extend Forwardable
  def_delegator   :@screens, :current, :current_screen
  def_delegators  :current_screen, :current_tag
  def_delegators  :current_tag, :current_col
  def_delegators  :current_col, :suggest_geo_for

  attr_reader :screens

  def screens=(screens)
    @screens = Container.new(screens.map { |id, geo| Screen.new(id, geo) })
  end

  def <<(client)
    current_col << client
    client.moveresize
    client.show
    client.focus
  end

  def remove(client)
  end
end
