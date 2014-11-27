class Layout
  class Tag
    extend Forwardable
    def_delegator :@cols, :current, :current_col
    def_delegator :current_col, :==, :current_col?

    attr_reader :id, :cols

    def initialize(id, geo)
      @id   = id
      @geo  = geo
      @cols = Container.new([Col.new(geo.dup)])
    end

    def to_s
      "TAG ##{@id}, geo: #{@geo}"
    end

    def ==(other)
      @id == other.id
    end
  end
end
