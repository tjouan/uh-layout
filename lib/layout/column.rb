class Layout
  class Column
    OPTIMAL_WIDTH = 484

    class << self
      def set!(columns, direction)
        return if columns.size <= 1 && columns.current.clients.size <= 1
        columns.current.remove client = columns.current.current_client
        dest_column = get_or_create columns, direction
        dest_column << client
        dest_column.current_client = client
        columns.delete_if &:empty?
        columns.current = dest_column
      end

      def arrange!(columns, geo, column_width: OPTIMAL_WIDTH)
        columns.each_with_index do |column, i|
          column.geo.x      = column_width * i + geo.x
          column.geo.width  = column_width
        end
        columns.last.geo.width = geo.width - columns.last.geo.x
      end


      private

      def get_or_create(columns, direction)
        columns.get(direction) or new(columns.current.geo).tap do |o|
          columns << o
        end
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
