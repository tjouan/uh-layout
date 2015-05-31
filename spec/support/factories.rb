require 'uh/wm/client'

module Factories
  class Entry
    include Uh::GeoAccessors

    attr_accessor :geo

    def initialize(geo)
      @geo = geo
    end
  end

  def build_client
    Uh::WM::Client.new(instance_spy Uh::Window)
  end

  def build_entry(geo = build_geo)
    Entry.new(geo)
  end

  def build_geo(x = 0, y = 0, width = 640, height = 480)
    Uh::Geo.new(x, y, width, height)
  end
end
