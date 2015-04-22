require 'forwardable'

require 'uh/layout/arrangers/fixed_width'
require 'uh/layout/arrangers/stack'
require 'uh/layout/arrangers/vert_tile'
require 'uh/layout/bar'
require 'uh/layout/client_column_mover'
require 'uh/layout/container'
require 'uh/layout/column'
require 'uh/layout/dumper'
require 'uh/layout/history'
require 'uh/layout/registrant'
require 'uh/layout/screen'
require 'uh/layout/tag'

module Uh
  class Layout
    Error         = Class.new(StandardError)
    RuntimeError  = Class.new(RuntimeError)
    ArgumentError = Class.new(Error)

    COLORS = {
      fg:   'rgb:d0/d0/d0'.freeze,
      bg:   'rgb:0c/0c/0c'.freeze,
      sel:  'rgb:d7/00/5f'.freeze,
      hi:   'rgb:82/00/3a'.freeze
    }.freeze

    extend Forwardable
    def_delegator :@screens, :current, :current_screen
    def_delegator :current_screen, :==, :current_screen?
    def_delegator :current_screen, :current_tag
    def_delegator :current_tag, :current_column

    attr_reader :screens, :widgets, :colors, :history

    def initialize
      @screens  = Container.new
      @widgets  = []
      @colors   = COLORS
      @history  = History.new
    end

    def register(display)
      Registrant.register self, display
    end

    def to_s
      Dumper.new(self).to_s
    end

    def current_client
      current_column and current_column.current_client
    end

    def include?(client)
      screens.any? { |screen| screen.include? client }
    end

    def update_widgets
      @widgets.each &:update
      @widgets.each &:redraw
    end

    def suggest_geo
      (current_column or current_tag).geo.dup
    end

    def <<(client)
      current_tag.current_column_or_create << client
      current_column.current_client = client
      current_column.arrange_clients
      current_column.show_hide_clients
      client.focus
      update_widgets
      self
    end
    alias push <<

    def remove(client)
      screen, tag, column = find_client client
      column.remove client
      tag.arrange_columns
      column.show_hide_clients
      current_client.focus if current_client
      update_widgets
    end

    def update client
      update_widgets unless client.hidden?
    end

    def expose window
      update_widgets
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
      tag_id = tag_id.to_s
      return unless current_tag.id != tag_id
      @history.record_tag current_tag
      current_tag.hide
      current_screen.tags.current = find_tag_or_create tag_id
      current_tag.each_column &:show_hide_clients
      current_client.focus if current_client
      update_widgets
    end

    def handle_tag_set(tag_id)
      return unless current_client && current_tag.id != tag_id
      previous_tag_id = current_tag.id
      remove client = current_client
      handle_tag_sel tag_id
      push client
      handle_tag_sel previous_tag_id
    end

    def handle_column_sel(direction)
      return unless current_tag.columns.any?
      current_tag.columns.sel direction
      current_client.focus
      update_widgets
    end

    def handle_column_mode_toggle
      return unless current_column
      current_column.mode_toggle
      current_column.arrange_clients
      current_column.show_hide_clients
    end

    def handle_client_sel(direction)
      return unless current_client
      current_column.clients.sel direction
      current_column.show_hide_clients
      current_client.focus
      update_widgets
    end

    def handle_client_swap(direction)
      return unless current_client && current_column.clients.size >= 2
      current_column.client_swap direction
      update_widgets
    end

    def handle_client_column_set(direction, mover: client_mover_for_current_tag)
      return unless current_client
      mover.move_current direction
      current_tag.arrange_columns
      current_tag.each_column &:show_hide_clients
      update_widgets
    end

    def handle_history_tag_pred
      handle_tag_sel @history.last_tag.id
    end

    def handle_kill_current
      current_client and current_client.kill
    end


    private

    def find_client(client)
      screens.each do |screen|
        screen.tags.each do |tag|
          tag.each_column do |column|
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

    def client_mover_for_current_tag
      ClientColumnMover.new(current_tag.columns, current_tag.columns_max_count?)
    end
  end
end
