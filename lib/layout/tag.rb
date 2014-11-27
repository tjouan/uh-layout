class Layout
  class Tag
    attr_reader :id, :cols

    def initialize(id, geo)
      @id   = id
      @geo  = geo
      @cols = Container.new([Col.new(geo.dup)])
    end

    def ==(other)
      @id == other.id
    end

    def suggest_geo_for(window)
      @geo
    end
  end
end
