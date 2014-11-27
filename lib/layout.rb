class Layout
  include Holo

  def suggest_geo_for(window)
    Geo.new(0, 0, 320, 240)
  end

  def <<(client)
    client.geo = Geo.new(0, 0, 320, 240)
    client.moveresize
    client.show
    client.focus
  end

  def remove(client)
  end
end
