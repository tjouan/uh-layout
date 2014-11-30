require 'layout'

class Layout
  describe Tag do
    let(:geo)       { Geo.new(0, 0, 640, 480) }
    let(:other_geo) { Geo.new(640, 0, 320, 240) }
    subject(:tag)   { described_class.new(0, geo) }

    it 'has one default col assigned' do
      expect(tag.cols).to include an_instance_of Col
    end

    describe '#==' do
      it 'equals another tag with same id' do
        expect(tag).to eq described_class.new(0, other_geo)
      end

      it 'does not equal another tag with different id' do
        expect(tag).not_to eq described_class.new(1, geo)
      end
    end

    describe '#clients' do
      it 'returns all clients contained in assigned cols' do
        some_client   = instance_spy WM::Client
        other_client  = instance_spy WM::Client
        tag.current_col << some_client << other_client
        expect(tag.clients).to eq [some_client, other_client]
      end
    end
  end
end
