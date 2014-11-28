class Layout
  class Col
    extend Forwardable
    def_delegators :@clients, :empty?, :include?, :remove
    def_delegator :@clients, :current, :current_client
    def_delegator :current_client, :==, :current_client?

    attr_reader :geo, :clients

    def initialize(geo)
      @geo      = geo.dup
      @clients  = Container.new
    end

    def to_s
      "COL geo: #{@geo}"
    end

    def ==(other)
      @geo == other.geo
    end

    def <<(client)
      client.geo = suggest_geo_for client.window
      @clients << client
    end

    def suggest_geo_for(window)
      @geo
    end
  end
end
