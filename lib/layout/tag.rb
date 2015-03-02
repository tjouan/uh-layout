class Layout
  class Tag
    include GeoAccessors

    extend Forwardable
    def_delegator :@columns, :current, :current_column
    def_delegator :@columns, :current=, :current_column=
    def_delegator :current_column, :==, :current_column?
    def_delegator :clients, :each, :each_client

    attr_reader :id, :geo, :columns

    def initialize(id, geo)
      unless id.kind_of? String
        fail ArgumentError, "expect `id' to be a String, #{id.class} given"
      end
      @id       = id
      @geo      = geo.dup
      @columns  = Container.new
    end

    def to_s
      "TAG ##{@id}, geo: #{@geo}"
    end

    def clients
      @columns.inject([]) { |m, column| m + column.clients }
    end

    def include?(client)
      @columns.any? { |column| column.include? client }
    end

    def current_column_or_create
      current_column or Column.new(@geo).tap do |column|
        @columns << column
      end
    end

    def hide
      clients.each &:hide
    end
  end
end
