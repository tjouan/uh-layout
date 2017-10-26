module Uh
  class Layout
    class ClientColumnMover
      def initialize columns, columns_max_count
        @columns            = columns
        @columns_max_count  = columns_max_count
      end

      def move_current direction
        @columns.current.remove client = @columns.current.current_client
        dest_column = get_or_create_column direction
        dest_column << client
        dest_column.current_client = client
        @columns.current = dest_column
      end

      def get_or_create_column direction
        if candidate = @columns.get(direction)
          candidate
        elsif @columns_max_count
          @columns.get direction, cycle: true
        else
          Column.new(Geo.new).tap do |o|
            case direction
              when :pred then @columns.unshift o
              when :succ then @columns << o
            end
          end
        end
      end
    end
  end
end
