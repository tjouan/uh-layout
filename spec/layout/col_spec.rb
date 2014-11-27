require 'layout'

class Layout
  describe Col do
    let(:geo)       { Geo.new(0, 0, 640, 480) }
    let(:other_geo) { Geo.new(640, 0, 320, 240) }
    let(:client)    { instance_spy WM::Client }
    subject(:col)   { described_class.new(geo) }

    it 'has no client assigned' do
      expect(col).to be_empty
    end

    describe '#==' do
      it 'equals another col with same geo' do
        expect(col).to eq described_class.new(geo)
      end

      it 'does not equal another col with different geo' do
        expect(col).not_to eq described_class.new(other_geo)
      end
    end

    describe '#<<' do
      it 'assigns suggested geo to given client' do
        col << client
        expect(client).to have_received(:geo=).with(col.suggest_geo_for :window)
      end
    end

    describe '#suggest_geo_for' do
      it 'returns the assigned geo' do
        expect(col.suggest_geo_for :window).to eq geo
      end
    end
  end
end
