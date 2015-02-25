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

    def update_clients_visibility
      @clients.each do |client|
        client.hide unless client.hidden? || @clients.current == client
      end
      @clients.current.show if @clients.current
    end
  end
end
