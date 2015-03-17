module Uh
  class Layout
    class Bar
      TEXT_PADDING_X    = 3
      TEXT_PADDING_Y    = 1
      BORDER_HEIGHT     = 2
      BORDER_PADDING_Y  = 0
      COLUMN_PADDING_X  = 1
      TAG_PADDING_X     = 5

      include GeoAccessors

      attr_writer :active

      def initialize(display, screen, colors)
        @display    = display
        @screen     = screen
        @geo        = build_geo @screen.geo
        @window     = @display.create_subwindow @geo
        @pixmap     = @display.create_pixmap width, height
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
        draw_columns BORDER_HEIGHT + BORDER_PADDING_Y,
          @screen.current_tag.columns, @screen.current_tag.current_column
        draw_tags BORDER_HEIGHT + BORDER_PADDING_Y + text_line_height,
          @screen.tags, @screen.current_tag
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
        bar_height = text_line_height * 2 + BORDER_HEIGHT + BORDER_PADDING_Y

        Uh::Geo.new(
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

      def column_offset_x(column)
        column.x - x
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
        @pixmap.draw_rect 0, 0, width, height
        @pixmap.gc_color active_color
        @pixmap.draw_rect 0, 0, width, BORDER_HEIGHT
      end

      def draw_columns(y_offset, columns, current_column)
        columns.each do |column|
          draw_column y_offset, column, column == current_column
        end
      end

      def draw_column(y_offset, column, current)
        x_offset = column_offset_x(column)
        if current
          @pixmap.gc_color @colors[:sel]
          @pixmap.draw_rect x_offset, y_offset, column.width, text_line_height
        end
        text_y = y_offset + @display.font.ascent + TEXT_PADDING_Y
        draw_text column_text(column), x_offset, y_offset,
          bg: current ? @colors[:hi] : @colors[:bg]
      end

      def draw_tags(y_offset, tags, current_tag)
        tags.sort_by(&:id).inject(0) do |x_offset, tag|
          color = if tag == current_tag
            active_color
          elsif tag.clients.any?
            @colors[:hi]
          else
            @colors[:bg]
          end

          x_offset + draw_text(tag.id, x_offset, y_offset,
            bg:         color,
            padding_x:  TAG_PADDING_X
          )
        end
      end

      def draw_text(text, x, y, bg: nil, padding_x: TEXT_PADDING_X)
        text        = text.to_s
        text_width  = text.length * @display.font.width + padding_x * 2
        text_y      = y + @display.font.ascent + TEXT_PADDING_Y
        if bg
          @pixmap.gc_color bg
          @pixmap.draw_rect x, y, text_width, text_line_height
        end
        @pixmap.gc_color @colors[:fg]
        @pixmap.draw_string x + padding_x, text_y, text
        text_width
      end
    end
  end
end
