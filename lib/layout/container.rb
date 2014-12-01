class Layout
  class Container
    include Enumerable

    extend Forwardable
    def_delegators :@entries, :<<, :[], :each, :empty?, :first, :delete_if,
      :last, :size

    attr_reader :entries

    def initialize(entries = [])
      @entries        = entries
      @current_index  = 0
    end

    alias to_ary entries

    def current
      @entries[@current_index]
    end

    def current=(entry)
      @current_index = @entries.index entry if include? entry
    end

    def remove(entry)
      fail ArgumentError, 'unknown entry' unless include? entry
      @entries.delete_at @entries.index entry
      @current_index -= 1
      self
    end

    def get(direction)
      index = @current_index.send(direction)
      index >= 0 ? self[index] : nil
    end

    def sel(direction)
      @current_index = @current_index.send(direction) % @entries.size
    end

    def set(direction)
      other_index = @current_index.send(direction)
      if other_index.between? 0, @entries.size - 1
        swap @current_index, other_index
        @current_index = other_index
      else
        rotate direction
        @current_index = other_index % @entries.size
      end
    end

    def swap(a, b)
      @entries[a], @entries[b] = @entries[b], @entries[a]
    end


    private

    def rotate(direction)
      case direction
      when :pred then @entries = @entries.push    @entries.shift
      when :succ then @entries = @entries.unshift @entries.pop
      end
    end
  end
end
