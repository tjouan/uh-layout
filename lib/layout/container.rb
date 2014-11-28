class Layout
  class Container
    include Enumerable

    extend Forwardable
    def_delegators :@entries, :<<, :each, :empty?

    attr_reader :entries

    def initialize(entries = [])
      @entries        = entries
      @current_index  = 0
    end

    def current
      @entries[@current_index]
    end

    def current=(entry)
      @current_index = @entries.index entry if include? entry
    end

    def remove(entry)
      @entries.delete_at @entries.index entry
      @current_index -= 1
      self
    end

    def sel(direction)
      @current_index = @current_index.send(direction) % @entries.size
    end
  end
end
