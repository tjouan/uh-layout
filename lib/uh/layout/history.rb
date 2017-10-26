module Uh
  class Layout
    class History
      VIEWS_SIZE_MAX = 8

      attr_reader :views, :views_size_max

      def initialize views = [], views_size_max: VIEWS_SIZE_MAX
        @views           = views
        @views_size_max  = views_size_max
      end

      def record_view view
        @views << view
        if @views.size > @views_size_max
          @views = @views.drop @views.size - @views_size_max
        end
      end

      def last_view
        @views.last
      end
    end
  end
end
