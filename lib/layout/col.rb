class Layout
  class Col
    extend Forwardable
    def_delegators :@clients, :empty?, :include?

    attr_reader :geo

    def initialize(geo)
      @geo      = geo
      @clients  = Container.new
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
