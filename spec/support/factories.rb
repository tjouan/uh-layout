module Factories
  def build_client
    Uh::WM::Client.new(instance_spy Uh::Window)
  end

  def build_geo(x = 0, y = 0, width = 640, height = 480)
    Uh::Geo.new(x, y, width, height)
  end
end
