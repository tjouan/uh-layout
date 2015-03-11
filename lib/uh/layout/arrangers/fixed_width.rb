module Uh
  class Layout
    module Arrangers
      class FixedWidth
        DEFAULT_WIDTH = 484

        def initialize(entries, geo, width: DEFAULT_WIDTH)
          @entries  = entries
          @geo      = geo
          @width    = width
        end

        def arrange
          return if @entries.empty?
          @entries.each_with_index do |column, i|
            column.x      = @width * i + @geo.x
            column.y      = @geo.y
            column.width  = @width
            column.height = @geo.height
          end
          @entries.last.width = @geo.width - (@entries.last.x - @geo.x)
        end

        def max_count?
          (@geo.width / (@entries.size + 1)) < @width
        end
      end
    end
  end
end
