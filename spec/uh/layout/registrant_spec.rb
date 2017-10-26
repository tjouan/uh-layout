module Uh
  class Layout
    RSpec.describe Registrant do
      let(:layout)  { Layout.new }
      let(:geo)     { build_geo }
      let(:screen)  { double 'screen', id: 0, geo: geo, height: geo.height }
      let(:display) { double 'display', screens: [screen] }
      let(:bar)     { instance_spy Bar, height: 16 }

      before do
        allow(Bar).to receive(:new) { bar }
      end

      describe '#register' do
        it 'registers display screens as layout screens' do
          described_class.register layout, display
          expect(layout.screens[0])
            .to be_a(Screen)
            .and have_attributes id: 0
        end

        it 'builds a new bar widget' do
          expect(Bar)
            .to receive(:new)
            .with display, an_instance_of(Screen), layout.colors
          described_class.register layout, display
        end

        it 'registers the bar widget' do
          described_class.register layout, display
          expect(layout.widgets[0]).to be bar
        end

        it 'decreases the layout screens height with the bar height' do
          described_class.register layout, display
          expect(layout.screens[0].height).to eq screen.height - bar.height
        end

        it 'updates layout widgets' do
          expect(layout).to receive :update_widgets
          described_class.register layout, display
        end
      end
    end
  end
end
