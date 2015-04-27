module Uh
  class Layout
    RSpec.describe Screen do
      let(:geo)         { build_geo }
      let(:other_geo)   { build_geo 640, 0, 320, 240 }
      let(:client)      { build_client }
      subject(:screen)  { described_class.new 0, geo }

      it 'has one default view with id 1 assigned' do
        expect(screen.views).to include an_object_having_attributes id: '1'
      end

      it 'has one default view with screen geo copy assigned' do
        expect(screen.views.first.geo).to eq(screen.geo).and not_be screen.geo
      end

      describe '#height=' do
        it 'changes screen height' do
          expect { screen.height = 42 }.to change { screen.height }.to 42
        end

        it 'changes views height' do
          expect { screen.height = 42 }
            .to change { screen.views.first.height }.to 42
        end
      end

      describe '#include?' do
        it 'returns false when screen does not include given client' do
          expect(screen.include? client).to be false
        end

        it 'returns true when screen includes given client' do
          screen.current_view.current_column_or_create << client
          expect(screen.include? client).to be true
        end
      end
    end
  end
end
