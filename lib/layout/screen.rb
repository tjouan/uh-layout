class Layout
  class Screen
    extend Forwardable
    def_delegator :@tags, :current, :current_tag

    attr_reader :id, :tags

    def initialize(id, geo)
      @id   = id
      @geo  = geo
      @tags = Container.new([Tag.new(1, geo)])
    end

    def ==(other)
      @id == other.id
    end
  end
end
