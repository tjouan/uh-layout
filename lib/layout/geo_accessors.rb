class Layout
  module GeoAccessors
    extend Forwardable
    def_delegators :@geo,
      :x, :y, :width, :height,
      :x=, :y=, :width=, :height=
  end
end
