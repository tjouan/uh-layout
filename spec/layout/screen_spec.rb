require 'layout'

class Layout
  describe Screen do
    let(:geo)         { build_geo }
    let(:other_geo)   { build_geo 640, 0, 320, 240 }
    subject(:screen)  { described_class.new(0, geo) }

    it 'has one default tag with id 1 assigned' do
      expect(screen.tags).to include an_object_having_attributes id: '1'
    end

    it 'has one default tag with screen geo copy assigned' do
      expect(screen.tags.first.geo).to eq(screen.geo).and not_be screen.geo
    end

    describe '#height=' do
      it 'changes screen height' do
        expect { screen.height = 42 }.to change { screen.height }.to 42
      end

      it 'changes tags height' do
        expect { screen.height = 42 }
          .to change { screen.tags.first.height }.to 42
      end
    end
  end
end
