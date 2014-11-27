class Layout
  require 'forwardable'
  require 'layout/container'
  require 'layout/col'
  require 'layout/screen'
  require 'layout/tag'

  include Holo

  extend Forwardable
  def_delegator   :@screens, :current, :current_screen
  def_delegator   :current_screen, :==, :current_screen?
  def_delegators  :current_screen, :current_tag
  def_delegators  :current_tag, :current_col
  def_delegators  :current_col, :suggest_geo_for

  attr_reader :screens

  def screens=(screens)
    @screens = Container.new(screens.map { |id, geo| Screen.new(id, geo) })
  end

  def to_s
    screens.inject('') do |m, screen|
      m << "%s%s\n" % [current_screen?(screen) ? '*' : ' ', screen]
      screen.tags.each do |tag|
        m << "  %s%s\n" % [screen.current_tag?(tag) ? '*' : ' ', tag]
        tag.cols.each do |col|
          m << "    %s%s\n" % [tag.current_col?(col) ? '*' : ' ', col]
          col.clients.each do |client|
            m << "      %s%s\n" % [
              col.current_client?(client) ? '*' : ' ',
              client
            ]
          end
        end
      end
      m
    end
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
