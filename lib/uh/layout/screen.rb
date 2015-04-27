module Uh
  class Layout
    class Screen
      include GeoAccessors

      extend Forwardable
      def_delegator :@views, :current, :current_view
      def_delegator :current_view, :==, :current_view?

      attr_reader :id, :views, :geo

      def initialize(id, geo)
        @id     = id
        @geo    = geo.dup
        @views  = Container.new([View.new('1', @geo)])
      end

      def to_s
        "SCREEN ##{@id}, geo: #{@geo}"
      end

      def height=(value)
        @geo.height = value
        @views.each { |view| view.height = value }
      end

      def include?(client)
        @views.any? { |view| view.include? client }
      end
    end
  end
end
