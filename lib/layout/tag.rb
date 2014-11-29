class Layout
  class Tag
    extend Forwardable
    def_delegator :@cols, :current, :current_col
    def_delegator :current_col, :==, :current_col?
    def_delegator :clients, :each, :each_client

    attr_reader :id, :geo, :cols

    def initialize(id, geo)
      @id   = id
      @geo  = geo.freeze
      @cols = Container.new([Col.new(geo.dup)])
    end

    def to_s
      "TAG ##{@id}, geo: #{@geo}"
    end

    def ==(other)
      @id == other.id
    end

    def clients
      @cols.inject([]) { |m, col| m + col.clients }
    end
  end
end
