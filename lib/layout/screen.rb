class Layout
  class Screen
    extend Forwardable
    def_delegator :@tags, :current, :current_tag
    def_delegator :current_tag, :==, :current_tag?
    def_delegator :@geo, :height

    attr_reader :id, :tags, :geo

    def initialize(id, geo)
      @id   = id
      @geo  = geo.dup
      @tags = Container.new([Tag.new('1', @geo)])
    end

    def to_s
      "SCREEN ##{@id}, geo: #{@geo}"
    end

    def height=(value)
      @geo.height = value
    end
  end
end
