module Uh
  class Layout
    module Registrant
      class << self
        def register(layout, display)
          display.screens.each do |screen|
            layout.screens << scr = Screen.new(screen.id, screen.geo)
            bar = Bar.new(display, scr, layout.colors).tap do |b|
              layout.widgets << b.show.focus
              b.on_update do
                bar.active = layout.current_screen? scr
                bar.status = layout.bar_status.call if layout.bar_status
              end
            end
            scr.height = scr.height - bar.height
          end
          layout.update_widgets
        end
      end
    end
  end
end
