require 'layout/screen'

module Holo
  describe Layout::Screen do
    let(:geo)         { Geo.new(0, 0, 640, 480) }
    let(:other_geo)   { Geo.new(640, 0, 320, 240) }
    subject(:screen)  { described_class.new(0, geo) }

    describe '#==' do
      it 'equals another screen with same id' do
        expect(screen).to eq described_class.new(0, other_geo)
      end

      it 'does not equal another screen with different id' do
        expect(screen).not_to eq described_class.new(1, geo)
      end
    end

    describe '#suggest_geo_for' do
      it 'returns the assigned geo' do
        expect(screen.suggest_geo_for :window).to eq geo
      end
    end
  end
end
