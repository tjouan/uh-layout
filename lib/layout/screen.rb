class Layout
  class Screen
    extend Forwardable
    def_delegator :@tags, :current, :current_tag
    def_delegators :current_tag, :suggest_geo_for

    attr_reader :id, :tags

    def initialize(id, geo)
      @id   = id
      @geo  = geo
      @tags = Container.new([Tag.new(1, geo)])
    end

    def ==(other)
      @id == other.id
    end
  end
end
