class Layout
  class Column
    class Arranger
      OPTIMAL_WIDTH = 484

      attr_reader :columns, :geo

      def initialize(columns, geo)
        @columns  = columns
        @geo      = geo
      end

      def move_current_client(direction)
        return self if @columns.size <= 1 && @columns.current.clients.size <= 1
        @columns.current.remove client = @columns.current.current_client
        dest_column = get_or_create direction
        dest_column << client
        dest_column.current_client = client
        @columns.delete_if &:empty?
        @columns.current = dest_column
        self
      end

      def arrange(column_width: OPTIMAL_WIDTH)
        @columns.each_with_index do |column, i|
          column.geo.x      = column_width * i + geo.x
          column.geo.width  = column_width
        end
        @columns.last.geo.width = geo.width - columns.last.geo.x
      end


      private

      def get_or_create(direction)
        @columns.get(direction) or Column.new(@geo).tap do |o|
          @columns << o
        end
      end
    end
  end
end
