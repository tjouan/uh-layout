class Layout
  class Tag
    extend Forwardable
    def_delegator :@columns, :current, :current_column
    def_delegator :@columns, :current=, :current_column=
    def_delegator :current_column, :==, :current_column?
    def_delegator :clients, :each, :each_client

    attr_reader :id, :geo, :columns

    def initialize(id, geo)
      @id       = id
      @geo      = geo
      @columns  = Container.new
    end

    def to_s
      "TAG ##{@id}, geo: #{@geo}"
    end

    def clients
      @columns.inject([]) { |m, column| m + column.clients }
    end

    def suggest_geo_for(window)
      @geo
    end
  end
end
