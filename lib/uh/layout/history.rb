module Uh
  class Layout
    class History
      TAGS_SIZE_MAX = 8

      attr_reader :tags, :tags_size_max

      def initialize(tags = [], tags_size_max: TAGS_SIZE_MAX)
        @tags           = tags
        @tags_size_max  = tags_size_max
      end

      def record_tag(tag)
        @tags << tag
        if @tags.size > @tags_size_max
          @tags = @tags.drop @tags.size - @tags_size_max
        end
      end

      def last_tag
        @tags.last
      end
    end
  end
end
