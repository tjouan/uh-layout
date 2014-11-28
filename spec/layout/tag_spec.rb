require 'layout'

class Layout
  describe Tag do
    let(:geo)       { Geo.new(0, 0, 640, 480) }
    let(:other_geo) { Geo.new(640, 0, 320, 240) }
    subject(:tag)   { described_class.new(0, geo) }

    it 'has one default col assigned' do
      expect(tag.cols).to include Col.new(geo)
    end

    describe '#==' do
      it 'equals another tag with same id' do
        expect(tag).to eq described_class.new(0, other_geo)
      end

      it 'does not equal another tag with different id' do
        expect(tag).not_to eq described_class.new(1, geo)
      end
    end
  end
end
