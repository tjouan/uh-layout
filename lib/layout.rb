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
  def_delegators  :current_col, :current_client, :suggest_geo_for

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
    current_col.current_client = client
    client.moveresize
    client.show
    client.focus
    self
  end

  def remove(client)
    current_col.remove client
    current_client.focus if current_client
  end

  def handle_screen_sel(direction)
    screens.sel direction
    current_client.focus if current_client
  end

  def handle_client_sel(direction)
    current_col.clients.sel direction
    current_client.focus
  end

  def handle_client_swap(direction)
    current_col.clients.set direction
  end

  def handle_client_col_set(direction)
    Col.set! current_tag.cols, direction
    Col.arrange! current_tag.cols, current_tag.geo
    current_tag.each_client &:moveresize
  end

  def handle_kill_current
    current_client.kill
  end
end
