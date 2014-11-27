class Layout
  class Container
    attr_reader :entries

    def initialize(entries)
      @entries        = entries
      @current_index  = 0
    end

    def current
      @entries[@current_index]
    end
  end
end
