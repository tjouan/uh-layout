class Layout
  class Container
    extend Forwardable
    def_delegators :@entries, :<<, :empty?, :include?

    attr_reader :entries

    def initialize(entries = [])
      @entries        = entries
      @current_index  = 0
    end

    def current
      @entries[@current_index]
    end
  end
end
