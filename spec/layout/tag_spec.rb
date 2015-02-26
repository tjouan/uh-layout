require 'layout'

class Layout
  describe Tag do
    let(:geo)       { Holo::Geo.new(0, 0, 640, 480) }
    let(:other_geo) { Holo::Geo.new(640, 0, 320, 240) }
    subject(:tag)   { described_class.new(0, geo) }

    describe '#clients' do
      it 'returns all clients contained in assigned columns' do
        some_client = instance_spy Holo::WM::Client
        other_client = instance_spy Holo::WM::Client
        tag.columns << Column.new(tag.geo)
        tag.current_column << some_client << other_client
        expect(tag.clients).to eq [some_client, other_client]
      end
    end
  end
end
