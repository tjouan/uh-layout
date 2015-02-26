class Layout
  class Column
    extend Forwardable
    def_delegators :@clients, :empty?, :include?, :remove
    def_delegator :@clients, :current, :current_client
    def_delegator :@clients, :current=, :current_client=
    def_delegator :current_client, :==, :current_client?

    attr_reader :geo, :clients

    def initialize(geo)
      @geo      = geo.dup
      @clients  = Container.new
    end

    def to_s
      "COL geo: #{@geo}"
    end

    def <<(client)
      client.geo = suggest_geo
      @clients << client
      self
    end

    def suggest_geo
      @geo
    end
  end
end
