module Factories
  class Entry
    include Uh::GeoAccessors

    attr_accessor :geo

    def initialize geo
      @geo = geo
    end
  end

  class ClientMock
    include Uh::GeoAccessors

    attr_accessor :geo

    def hidden?
      !@visible
    end

    def moveresize
      self
    end

    def show
      @visible = true
      self
    end

    def hide
      @visible = false
      self
    end

    def focus
      self
    end
  end

  def build_client
    ClientMock.new
  end

  def build_entry geo = build_geo
    Entry.new geo
  end

  def build_geo x = 0, y = 0, width = 640, height = 480
    Uh::Geo.new x, y, width, height
  end
end
