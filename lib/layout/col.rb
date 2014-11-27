class Layout
  class Col
    attr_reader :geo

    def initialize(geo)
      @geo = geo
    end

    def ==(other)
      @geo == other.geo
    end

    def suggest_geo_for(window)
      @geo
    end
  end
end
