module Uh
  class Layout
    class Dumper
      def initialize(layout)
        @layout = layout
      end

      def to_s
        @layout.screens.inject('') do |m, screen|
          m << "%s%s\n" % [@layout.current_screen?(screen) ? '*' : ' ', screen]
          screen.tags.each do |tag|
            m << "  %s%s\n" % [screen.current_tag?(tag) ? '*' : ' ', tag]
            tag.columns.each do |column|
              m << "    %s%s\n" % [tag.current_column?(column) ? '*' : ' ', column]
              column.clients.each do |client|
                m << "      %s%s\n" % [
                  column.current_client?(client) ? '*' : ' ',
                  client
                ]
              end
            end
          end
          m
        end
      end
    end
  end
end
