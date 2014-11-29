class Layout
  class Col
    OPTIMAL_WIDTH = 484

    class << self
      def set!(cols, direction)
        return if cols.size <= 1 && cols.current.clients.size <= 1
        cols.current.remove client = cols.current.current_client
        dest_col = get_or_create cols, direction
        dest_col << client
        dest_col.current_client = client
        cols.delete_if &:empty?
        cols.current = dest_col
      end

      def arrange!(cols, geo, col_width: OPTIMAL_WIDTH)
        cols.each_with_index do |col, i|
          col.geo.x     = col_width * i
          col.geo.width = col_width
        end
        cols.last.geo.width = geo.width - cols.last.geo.x
      end


      private

      def get_or_create(cols, direction)
        cols.get(direction) or new(cols.current.geo).tap { |o| cols << o }
      end
    end

    extend Forwardable
    def_delegators :@clients, :empty?, :include?, :remove
    def_delegator :@clients, :current, :current_client
    def_delegator :@clients, :current=, :current_client=
    def_delegator :current_client, :==, :current_client?

    attr_reader :geo, :clients

    def initialize(geo)
      @geo      = geo.dup
      @clients  = Container.new
    end

    def to_s
      "COL geo: #{@geo}"
    end

    def <<(client)
      client.geo = suggest_geo_for client.window
      @clients << client
      self
    end

    def suggest_geo_for(window)
      @geo
    end
  end
end
