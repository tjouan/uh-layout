class Layout
  class Bar
    COLOR                       = 'rgb:d7/00/5f'.freeze
    COLOR_ALT                   = 'rgb:82/00/3a'.freeze
    COLUMN_WIDGET_MARGIN_TOP    = 0
    COLUMN_WIDGET_HEIGHT        = 2
    COLUMN_WIDGET_PADDING_X     = 1
    TAG_WIDGET_PADDING          = 5
    TAG_WIDGET_WIDTH            = 15
    TEXT_PADDING                = 1

    extend Forwardable
    def_delegators :@geo, :width, :height

    attr_reader :geo
    attr_writer :active

    def initialize(display, screen)
      @display    = display
      @screen     = screen
      @geo        = build_geo @screen.geo
      @window     = @display.create_subwindow @geo
      @pixmap     = @display.create_pixmap @geo.width, @geo.height
      @color      = @display.color_by_name COLOR
      @color_alt  = @display.color_by_name COLOR_ALT
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
      bar_height = text_line_height * 2 + COLUMN_WIDGET_HEIGHT + 1

      Holo::Geo.new(
        layout_geo.x,
        layout_geo.height - bar_height,
        layout_geo.width,
        bar_height
      )
    end

    def active_color
      active? ? @color : @color_alt
    end

    def text_line_height
      @display.font.height + TEXT_PADDING * 2
    end

    def column_widget_text_y
      COLUMN_WIDGET_MARGIN_TOP + COLUMN_WIDGET_HEIGHT
    end

    def column_widget_height
      column_widget_text_y + text_line_height + 1
    end

    def column_offset_x(column)
      column.geo.x - @geo.x
    end

    def draw_background
      @pixmap.gc_black
      @pixmap.draw_rect 0, 0, geo.width, geo.height
    end

    def draw_columns(columns, current_column)
      columns.each do |column|
        draw_column column, column == current_column
      end
    end

    def draw_column(column, current)
      @pixmap.gc_color current ? active_color : @color_alt
      @pixmap.draw_rect column_offset_x(column) + COLUMN_WIDGET_PADDING_X,
        COLUMN_WIDGET_MARGIN_TOP,
        column.geo.width - COLUMN_WIDGET_PADDING_X, COLUMN_WIDGET_HEIGHT
      @pixmap.gc_white
      text_y =
        column_widget_text_y + @display.font.ascent + TEXT_PADDING
      text = '%d/%d %s' % [
        column.clients.current_index,
        column.clients.size,
        column.current_client.to_s
      ]
      @pixmap.draw_string column_offset_x(column) + TEXT_PADDING,
        text_y, text
    end

    def draw_tags(tags, current_tag)
      tags.each_with_index do |t, i|
        draw_tag t, i, t == current_tag
      end
    end

    def draw_tag(tag, index, current)
      offset = index * TAG_WIDGET_WIDTH
      if current
        @pixmap.gc_color active_color
        @pixmap.draw_rect offset, column_widget_height,
          TAG_WIDGET_WIDTH, text_line_height
      end
      @pixmap.gc_white
      text_y = column_widget_height + @display.font.ascent + TEXT_PADDING
      @pixmap.draw_string offset + TAG_WIDGET_PADDING, text_y, tag.id.to_s
    end
  end
end
