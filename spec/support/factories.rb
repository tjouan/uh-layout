module Factories
  def build_client
    Holo::WM::Client.new(instance_spy Holo::Window)
  end

  def build_geo(x = 0, y = 0, width = 640, height = 480)
    Holo::Geo.new(x, y, width, height)
  end
end
