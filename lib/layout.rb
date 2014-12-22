class Layout
  require 'forwardable'
  require 'layout/container'
  require 'layout/column'
  require 'layout/column/arranger'
  require 'layout/screen'
  require 'layout/tag'

  include Holo

  extend Forwardable
  def_delegator   :@screens, :current, :current_screen
  def_delegator   :current_screen, :==, :current_screen?
  def_delegators  :current_screen, :current_tag
  def_delegators  :current_tag, :current_column

  attr_reader :screens

  def screens=(screens)
    @screens = Container.new(screens.map { |id, geo| Screen.new(id, geo) })
  end

  def to_s
    screens.inject('') do |m, screen|
      m << "%s%s\n" % [current_screen?(screen) ? '*' : ' ', screen]
      screen.tags.each do |tag|
        m << "  %s%s\n" % [screen.current_tag?(tag) ? '*' : ' ', tag]
        tag.columns.each do |column|
          m << "    %s%s\n" % [tag.current_column?(column) ? '*' : ' ', column]
          column.clients.each do |client|
            m << "      %s%s\n" % [
              column.current_client?(client) ? '*' : ' ',
              client
            ]
          end
        end
      end
      m
    end
  end

  def current_client
    current_column and current_column.current_client
  end

  def <<(client)
    current_column_or_create << client
    current_column.current_client = client
    client.moveresize
    client.show
    client.focus
    self
  end

  def remove(client)
    screens.each do |screen|
      screen.tags.each do |tag|
        tag.columns.each do |column|
          if column.include? client
            column.remove client
            Column::Arranger.new(tag.columns, tag.geo).redraw do
              tag.each_client &:moveresize
            end
          end
        end
      end
    end
    current_client.focus if current_client
  end

  def suggest_geo_for(window)
    (current_column or current_tag).suggest_geo_for window
  end

  def include?(client)
    screens.any? do |screen|
      screen.tags.any? do |tag|
        tag.columns.any? { |column| column.include? client }
      end
    end
  end

  def arranger_for_current_tag
    Column::Arranger.new(current_tag.columns, current_tag.geo)
  end

  def handle_screen_sel(direction)
    screens.sel direction
    current_client.focus if current_client
  end

  def handle_column_sel(direction)
    current_tag.columns.sel direction
    current_client.focus
  end

  def handle_client_sel(direction)
    current_column.clients.sel direction
    current_client.focus
  end

  def handle_client_swap(direction)
    current_column.clients.set direction
  end

  def handle_client_column_set(direction, arranger: arranger_for_current_tag)
    arranger.move_current_client(direction).update_geos
    current_tag.each_client &:moveresize
  end

  def handle_kill_current
    current_client.kill
  end


  private

  def current_column_or_create
    current_column or Column.new(current_tag.geo).tap do |column|
      current_tag.columns << column
      current_tag.current_column = column
    end
  end
end
