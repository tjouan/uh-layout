require 'layout'

class Layout
  describe Tag do
    let(:geo)       { Holo::Geo.new(0, 0, 640, 480) }
    let(:other_geo) { Holo::Geo.new(640, 0, 320, 240) }
    subject(:tag)   { described_class.new('1', geo) }

    describe '.new' do
      it 'raises error unless id converts to string' do
        expect { described_class.new(1, geo) }.to raise_error(TypeError)
      end
    end

    describe '#clients' do
      it 'returns all clients contained in assigned columns' do
        some_client = Holo::WM::Client.new(instance_spy Holo::Window)
        other_client = Holo::WM::Client.new(instance_spy Holo::Window)
        tag.columns << Column.new(tag.geo)
        tag.current_column << some_client << other_client
        expect(tag.clients).to eq [some_client, other_client]
      end
    end

    describe '#current_column_or_create' do
      context 'when tag has no column' do
        it 'creates a new column' do
          expect { tag.current_column_or_create }
            .to change { tag.columns.size }.from(0).to(1)
        end

        it 'returns the new column' do
          expect(tag.current_column_or_create).to eq tag.columns.current
        end
      end

      context 'when tag has a column' do
        let(:column) { Column.new(geo) }

        before { tag.columns << column }

        it 'does not create any column' do
          expect { tag.current_column_or_create }
            .not_to change { tag.columns.size }
        end

        it 'returns the current column' do
          expect(tag.current_column_or_create).to be column
        end
      end
    end
  end
end
