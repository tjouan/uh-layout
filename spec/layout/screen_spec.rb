require 'layout'

class Layout
  describe Screen do
    let(:geo)         { Holo::Geo.new(0, 0, 640, 480) }
    let(:other_geo)   { Holo::Geo.new(640, 0, 320, 240) }
    subject(:screen)  { described_class.new(0, geo) }

    it 'has one default tag with id 1 assigned' do
      expect(screen.tags).to include an_object_having_attributes id: '1'
    end

    it 'has one default tag with screen geo assigned' do
      expect(screen.tags.first.geo).to be screen.geo
    end

    describe '#height=' do
      it 'changes the height' do
        expect { screen.height = 42 }.to change { screen.height }.to 42
      end
    end
  end
end
