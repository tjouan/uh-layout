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

      it 'assigns suggested geo to given client' do
        expect(client).to have_received(:geo=).with(layout.suggest_geo_for :window)
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
  end
end
