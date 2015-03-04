module Uh
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

        def redraw
          purge
          update_geos
          yield if block_given?
        end

        def purge
          @columns.remove_if &:empty?
        end

        def move_current_client(direction)
          return self unless @columns.current.current_client
          @columns.current.remove client = @columns.current.current_client
          dest_column = get_or_create_column direction
          dest_column << client
          dest_column.current_client = client
          purge
          @columns.current = dest_column
          self
        end

        def get_or_create_column(direction)
          if candidate = @columns.get(direction)
            candidate
          elsif max_columns_count?
            @columns.get direction, cycle: true
          else
            Column.new(@geo).tap do |o|
              case direction
              when :pred then @columns.unshift o
              when :succ then @columns << o
              end
            end
          end
        end

        def max_columns_count?
          (@geo.width / (@columns.size + 1)) < @column_width
        end

        def update_geos
          return if @columns.empty?
          @columns.each_with_index do |column, i|
            column.x      = @column_width * i + @geo.x
            column.width  = @column_width
          end
          @columns.last.width = @geo.width - (@columns.last.x - @geo.x)
        end
      end
    end
  end
end
