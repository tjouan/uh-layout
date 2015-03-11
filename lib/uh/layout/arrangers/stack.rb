module Uh
  class Layout
    module Arrangers
      class Stack
        def initialize(entries, geo)
          @entries  = entries
          @geo      = geo
        end

        def arrange
          @entries.each { |e| e.geo = @geo.dup }
        end

        def each_visible
          yield @entries.current if @entries.current
        end

        def each_hidden
          ([*@entries] - [@entries.current]).each { |e| yield e }
        end
      end
    end
  end
end
