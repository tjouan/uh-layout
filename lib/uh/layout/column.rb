module Uh
  class Layout
    class Column
      MODES = {
        stack:  Arrangers::Stack,
        tile:   Arrangers::VertTile
      }.freeze

      include GeoAccessors

      extend Forwardable
      def_delegators :@clients, :empty?, :include?, :remove
      def_delegator :@clients, :current, :current_client
      def_delegator :@clients, :current=, :current_client=
      def_delegator :current_client, :==, :current_client?

      attr_reader :geo, :clients, :mode

      def initialize(geo, mode: :stack)
        @geo      = geo.dup
        @clients  = Container.new
        @mode     = mode
      end

      def to_s
        "COL geo: #{@geo}"
      end

      def <<(client)
        client.geo = @geo.dup
        if @clients.current
          @clients.insert_after_current client
        else
          @clients << client
        end
        self
      end

      def mode_toggle
        @mode = MODES.keys[(MODES.keys.index(@mode) + 1) % MODES.keys.size]
      end

      def arranger
        MODES[@mode].new @clients, @geo
      end

      def client_swap(direction)
        @clients.set direction
        if @mode == :tile
          arrange_clients
          show_hide_clients
        end
      end

      def arrange_clients
        arranger.arrange
        clients.each &:moveresize
      end

      def show_hide_clients(arranger: self.arranger)
        arranger.each_visible { |client| client.show if client.hidden? }
        arranger.each_hidden  { |client| client.hide unless client.hidden? }
      end
    end
  end
end
