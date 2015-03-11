module Uh
  class Layout
    module Arrangers
      class VertTile
        def initialize(entries, geo)
          @entries  = entries
          @geo      = geo
        end

        def arrange
          entry_height = @geo.height / @entries.size - 1
          @entries.each_with_index do |entry, i|
            entry.geo     = @geo.dup
            entry.y       = (entry_height + 1) * i
            entry.height  = entry_height
          end
        end

        def each_visible
          @entries.each { |e| yield e }
        end

        def each_hidden
        end
      end
    end
  end
end
