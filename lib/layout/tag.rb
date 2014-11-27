class Layout
  class Tag
    attr_reader :id

    def initialize(id, geo)
      @id   = id
      @geo  = geo
    end

    def ==(other)
      @id == other.id
    end

    def suggest_geo_for(window)
      @geo
    end
  end
end
