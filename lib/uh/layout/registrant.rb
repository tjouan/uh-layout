module Uh
  class Layout
    module Registrant
      class << self
        def register(layout, display)
          display.screens.each do |screen|
            layout.screens << scr = Screen.new(screen.id, screen.geo)
            layout.widgets << bar = Bar.new(display, scr, layout.colors).show.focus
            bar.on_update do
              bar.active = layout.current_screen? scr
            end
            scr.height = scr.height - bar.height
          end
          layout.update_widgets
        end
      end
    end
  end
end
