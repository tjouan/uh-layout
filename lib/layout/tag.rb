class Layout
  class Tag
    extend Forwardable
    def_delegator :@columns, :current, :current_column
    def_delegator :@columns, :current=, :current_column=
    def_delegator :current_column, :==, :current_column?
    def_delegator :clients, :each, :each_client

    attr_reader :id, :geo, :columns

    def initialize(id, geo)
      begin
        @id = id.to_str
      rescue NoMethodError
        fail TypeError, "cannot convert #{id.class} into String"
      end
      @geo      = geo
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
