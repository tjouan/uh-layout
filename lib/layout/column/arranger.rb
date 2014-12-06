class Layout
  class Column
    class Arranger
      OPTIMAL_WIDTH = 484

      attr_reader :columns, :geo

      def initialize(columns, geo, column_width: OPTIMAL_WIDTH)
        @columns      = columns
        @geo          = geo
        @column_width = column_width
      end

      def move_current_client(direction)
        return self unless @columns.current.current_client
        @columns.current.remove client = @columns.current.current_client
        dest_column = get_or_create_column direction
        dest_column << client
        dest_column.current_client = client
        @columns.delete_if &:empty?
        @columns.current = dest_column
        self
      end

      def get_or_create_column(direction)
        if candidate = @columns.get(direction)
          candidate
        elsif max_columns_count?
          @columns.get direction, cycle: true
        else
          Column.new(@geo).tap { |o| @columns << o }
        end
      end

      def max_columns_count?
        (geo.width / (@columns.size + 1)) < @column_width
      end

      def arrange
        @columns.each_with_index do |column, i|
          column.geo.x      = @column_width * i + geo.x
          column.geo.width  = @column_width
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
