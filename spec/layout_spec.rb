require 'layout'

module Holo
  describe Layout do
    let(:geo)         { Geo.new(0, 0, 640, 480) }
    subject(:layout)  { described_class.new }

    describe '#screens=' do
      it 'assigns given screens as Screen objects in a Container' do
        layout.screens = { 0 => geo }
        expect(layout.screens.entries).to eq [Layout::Screen.new(0, geo)]
      end
    end
  end
end
