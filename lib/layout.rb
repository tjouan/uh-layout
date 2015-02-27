require 'forwardable'

require_relative 'layout/bar'
require_relative 'layout/container'
require_relative 'layout/column'
require_relative 'layout/column/arranger'
require_relative 'layout/screen'
require_relative 'layout/tag'

class Layout
  extend Forwardable
  def_delegator   :@screens, :current, :current_screen
  def_delegator   :current_screen, :==, :current_screen?
  def_delegators  :current_screen, :current_tag
  def_delegators  :current_tag, :current_column

  attr_reader :screens, :widgets

  def initialize
    @screens  = Container.new
    @widgets  = []
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

  def suggest_geo
    (current_column or current_tag).geo
  end

  def <<(client)
    current_tag.current_column_or_create << client
    current_column.current_client = client
    client.moveresize
    current_column.update_clients_visibility
    client.focus
    update_widgets
    self
  end
  alias push <<

  def remove(client)
    screen, tag, column = find_client client
    column.remove client
    Column::Arranger.new(tag.columns, tag.geo).redraw do
      tag.each_client &:moveresize
    end
    column.update_clients_visibility
    current_client.focus if current_client
    update_widgets
  end

  def include?(client)
    screens.any? do |screen|
      screen.tags.any? { |tag| tag.include? client }
    end
  end

  def arranger_for_current_tag
    Column::Arranger.new(current_tag.columns, current_tag.geo)
  end

  def update_widgets
    @widgets.each &:update
    @widgets.each &:redraw
  end

  def handle_screen_sel(direction)
    screens.sel direction
    current_client.focus if current_client
    update_widgets
  end

  def handle_screen_set(direction)
    return unless current_client
    remove client = current_client
    screens.sel direction
    push client
  end

  def handle_tag_sel(tag_id)
    return unless current_tag.id != tag_id
    current_tag.hide
    current_screen.tags.current = find_tag_or_create tag_id
    current_tag.columns.each &:update_clients_visibility
    current_client.focus if current_client
    update_widgets
  end

  def handle_tag_set(tag_id)
    return unless current_client && current_tag.id != tag_id
    remove client = current_client
    client.hide
    tag = find_tag_or_create tag_id
    tag.current_column_or_create << client
    Column::Arranger.new(tag.columns, tag.geo).redraw do
      tag.each_client &:moveresize
    end
    current_client.focus if current_client
    update_widgets
  end

  def handle_column_sel(direction)
    return unless current_tag.columns.any?
    current_tag.columns.sel direction
    current_client.focus
    update_widgets
  end

  def handle_client_sel(direction)
    return unless current_client
    current_column.clients.sel direction
    current_column.update_clients_visibility
    current_client.focus
    update_widgets
  end

  def handle_client_swap(direction)
    return unless current_client
    current_column.clients.set direction
    update_widgets
  end

  def handle_client_column_set(direction, arranger: arranger_for_current_tag)
    return unless current_client
    arranger.move_current_client(direction).update_geos
    current_tag.each_client &:moveresize
    current_tag.columns.each &:update_clients_visibility
    update_widgets
  end

  def handle_kill_current
    current_client and current_client.kill
  end


  private

  def find_client(client)
    screens.each do |screen|
      screen.tags.each do |tag|
        tag.columns.each do |column|
          if column.include? client
            return screen, tag, column
          end
        end
      end
    end
  end

  def find_tag_or_create(tag_id)
    current_screen.tags.find { |e| e.id == tag_id } or Tag.new(tag_id, current_screen.geo).tap do |tag|
      current_screen.tags << tag
    end
  end
end
