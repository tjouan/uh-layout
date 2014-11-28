require 'layout'

module Holo
  describe Layout do
    let(:geo)         { Geo.new(0, 0, 640, 480) }
    let(:client)      { instance_spy WM::Client }
    subject(:layout)  { described_class.new }

    before { layout.screens = { 0 => geo } }

    describe '#screens=' do
      it 'assigns given screens as Screen objects in a Container' do
        expect(layout.screens.entries).to eq [Layout::Screen.new(0, geo)]
      end
    end

    describe '#<<' do
      before { layout << client }

      it 'adds given client to current col' do
        expect(layout.current_col).to include client
      end

      it 'moveresizes given client' do
        expect(client).to have_received :moveresize
      end

      it 'shows given client' do
        expect(client).to have_received :show
      end

      it 'focuses given client' do
        expect(client).to have_received :focus
      end
    end

    describe '#remove' do
      before do
        layout << client
        layout.remove client
      end

      it 'removes given client from current col' do
        expect(layout.current_col).not_to include client
      end
    end

    describe '#suggest_geo_for' do
      it 'returns current col suggested geo' do
        expect(layout.suggest_geo_for :window)
          .to eq layout.current_col.suggest_geo_for :window
      end
    end
  end
end
