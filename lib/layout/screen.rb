class Layout
  class Screen
    extend Forwardable
    def_delegator :@tags, :current, :current_tag
    def_delegator :current_tag, :==, :current_tag?

    attr_reader :id, :tags

    def initialize(id, geo)
      @id   = id
      @geo  = geo.freeze
      @tags = Container.new([Tag.new(1, geo)])
    end

    def to_s
      "SCREEN ##{@id}, geo: #{@geo}"
    end

    def ==(other)
      @id == other.id
    end
  end
end
