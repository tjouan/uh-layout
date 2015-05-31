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
require 'uh/layout/view'

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
    def_delegator :current_screen, :current_view
    def_delegator :current_view, :current_column

    attr_reader :screens, :widgets, :colors, :history

    def initialize **options
      @screens  = Container.new
      @widgets  = []
      @colors   = COLORS
      @history  = History.new

      @colors = @colors.merge options[:colors] if options.key? :colors
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
      (current_column or current_view).geo.dup
    end

    def <<(client)
      current_view.current_column_or_create << client
      current_column.current_client = client
      current_column.arrange_clients
      current_column.show_hide_clients
      client.focus
      update_widgets
      self
    end
    alias push <<

    def remove(client)
      screen, view, column = find_client client
      column.remove client
      view.arrange_columns
      column.show_hide_clients
      current_client.focus if current_client
      update_widgets
    end

    def update(client = nil)
      return if client && client.hidden?
      update_widgets
    end

    def expose(window)
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

    def handle_view_sel(view_id)
      view_id = view_id.to_s
      return unless current_view.id != view_id
      @history.record_view current_view
      current_view.hide
      current_screen.views.current = find_view_or_create view_id
      current_view.each_column &:show_hide_clients
      current_client.focus if current_client
      update_widgets
    end

    def handle_view_set(view_id)
      return unless current_client && current_view.id != view_id
      previous_view_id = current_view.id
      remove client = current_client
      handle_view_sel view_id
      push client
      handle_view_sel previous_view_id
    end

    def handle_column_sel(direction)
      return unless current_view.columns.any?
      current_view.columns.sel direction
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

    def handle_client_column_set(direction, mover: client_mover_for_current_view)
      return unless current_client
      mover.move_current direction
      current_view.arrange_columns
      current_view.each_column &:show_hide_clients
      update_widgets
    end

    def handle_history_view_pred
      handle_view_sel @history.last_view.id
    end


    private

    def find_client(client)
      screens.each do |screen|
        screen.views.each do |view|
          view.each_column do |column|
            if column.include? client
              return screen, view, column
            end
          end
        end
      end
    end

    def find_view_or_create(view_id)
      current_screen.views.find do
        |e| e.id == view_id
      end or View.new(view_id, current_screen.geo).tap do |view|
        current_screen.views << view
      end
    end

    def client_mover_for_current_view
      ClientColumnMover.new(
        current_view.columns,
        current_view.columns_max_count?
      )
    end
  end
end
