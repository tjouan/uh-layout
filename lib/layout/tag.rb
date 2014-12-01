class Layout
  class Tag
    extend Forwardable
    def_delegator :@columns, :current, :current_column
    def_delegator :current_column, :==, :current_column?
    def_delegator :clients, :each, :each_client

    attr_reader :id, :geo, :columns

    def initialize(id, geo)
      @id       = id
      @geo      = geo.freeze
      @columns  = Container.new([Column.new(geo.dup)])
    end

    def to_s
      "TAG ##{@id}, geo: #{@geo}"
    end

    def ==(other)
      @id == other.id
    end

    def clients
      @columns.inject([]) { |m, column| m + column.clients }
    end
  end
end
