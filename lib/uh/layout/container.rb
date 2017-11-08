module Uh
  class Layout
    class Container
      include Enumerable

      extend Forwardable
      def_delegators :@entries, :<<, :[], :each, :empty?, :fetch, :first,
        :index, :last, :size, :unshift

      def initialize entries = []
        @entries        = entries
        @current_index  = 0
      end

      alias to_ary entries

      def current
        @entries[@current_index]
      end

      def current= entry
        fail ArgumentError, 'unknown entry' unless include? entry
        @current_index = @entries.index entry
      end

      def insert_after_current entry
        fail RuntimeError, 'no current entry' unless current
        @entries.insert @current_index + 1, entry
      end

      def remove *entries
        entries.each { |e| remove_entry e }
        @entries.each { |e| remove_entry e if yield e } if block_given?
        self
      end

      def get direction, cycle: false
        index = @current_index.send direction
        if cycle
          @entries[index % @entries.size]
        else
          index >= 0 ? self[index] : nil
        end
      end

      def sel direction
        @current_index = @current_index.send(direction) % @entries.size
      end

      def set direction
        fail RuntimeError unless @entries.size >= 2
        new_index = @current_index.send direction
        if new_index.between? 0, @entries.size - 1
          swap @current_index, new_index
          @current_index = new_index
        else
          rotate direction
          @current_index = new_index % @entries.size
        end
      end

      def swap a, b
        @entries[a], @entries[b] = @entries[b], @entries[a]
      end

    private

      def remove_entry entry
        fail ArgumentError, 'unknown entry' unless include? entry
        @entries.delete_at (index = @entries.index(entry))
        if @current_index != 0 && @current_index > index
          @current_index -= 1
        end
      end

      def rotate direction
        @entries = @entries.rotate case direction
          when :pred then 1
          when :succ then -1
        end
      end
    end
  end
end
