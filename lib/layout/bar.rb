class Layout
  class Bar
    TEXT_PADDING_X    = 1
    TEXT_PADDING_Y    = 1
    COLUMN_MARGIN_TOP = 0
    COLUMN_HEIGHT     = 2
    COLUMN_PADDING_X  = 1
    TAG_PADDING_X     = 5

    extend Forwardable
    def_delegators :@geo, :width, :height

    attr_reader :geo
    attr_writer :active

    def initialize(display, screen, colors)
      @display    = display
      @screen     = screen
      @geo        = build_geo @screen.geo
      @window     = @display.create_subwindow @geo
      @pixmap     = @display.create_pixmap @geo.width, @geo.height
      @colors     = Hash[colors.map { |k, v| [k, @display.color_by_name(v)] }]
      @on_update  = proc { }
    end

    def active?
      !!@active
    end

    def on_update(&block)
      @on_update = block
    end

    def update
      @on_update.call
    end

    def redraw
      draw_background
      draw_columns @screen.current_tag.columns,
        @screen.current_tag.current_column
      draw_tags @screen.tags, @screen.current_tag
      blit
    end

    def show
      @window.show
      self
    end

    def focus
      @window.focus
      self
    end


    private

    def blit
      @pixmap.copy @window
      self
    end

    def build_geo(layout_geo)
      bar_height = text_line_height * 2 + COLUMN_HEIGHT + 1

      Holo::Geo.new(
        layout_geo.x,
        layout_geo.height - bar_height,
        layout_geo.width,
        bar_height
      )
    end

    def active_color
      active? ? @colors[:sel] : @colors[:hi]
    end

    def text_line_height
      @display.font.height + TEXT_PADDING_Y * 2
    end

    def column_widget_text_y
      COLUMN_MARGIN_TOP + COLUMN_HEIGHT
    end

    def column_widget_height
      column_widget_text_y + text_line_height + 1
    end

    def column_offset_x(column)
      column.geo.x - @geo.x
    end

    def column_text(column)
      text = '%d/%d %s (%s)' % [
        column.clients.index(column.current_client),
        column.clients.size,
        column.current_client.name,
        column.current_client.wclass
      ]
    end

    def draw_background
      @pixmap.gc_color @colors[:bg]
      @pixmap.draw_rect 0, 0, geo.width, geo.height
    end

    def draw_columns(columns, current_column)
      columns.each do |column|
        draw_column column, column == current_column
      end
    end

    def draw_column(column, current)
      @pixmap.gc_color current ? active_color : @colors[:hi]
      @pixmap.draw_rect column_offset_x(column) + COLUMN_PADDING_X,
        COLUMN_MARGIN_TOP,
        column.geo.width - COLUMN_PADDING_X, COLUMN_HEIGHT
      @pixmap.gc_color @colors[:fg]
      text_y =
        column_widget_text_y + @display.font.ascent + TEXT_PADDING_Y
      @pixmap.draw_string column_offset_x(column) + TEXT_PADDING_Y,
        text_y, column_text(column)
    end

    def draw_tags(tags, current_tag)
      tags.sort_by(&:id).inject(0) do |offset, tag|
        offset + draw_text(
          tag.id, offset, column_widget_height,
          @colors[:fg], tag == current_tag ? active_color : @colors[:hi],
          TAG_PADDING_X
        )
      end
    end

    def draw_text(text, x, y, color_fg = @colors[:fg], color_bg = nil,
        padding_x = TEXT_PADDING_X)
      text        = text.to_s
      text_width  = text.length * @display.font.width + padding_x * 2
      text_y      = y + @display.font.ascent + TEXT_PADDING_Y
      if color_bg
        @pixmap.gc_color color_bg
        @pixmap.draw_rect x, y, text_width, text_line_height
      end
      @pixmap.gc_color color_fg
      @pixmap.draw_string x + padding_x, text_y, text
      text_width
    end
  end
end
