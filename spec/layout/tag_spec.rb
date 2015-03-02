require 'layout'

class Layout
  describe Tag do
    let(:geo)           { build_geo }
    let(:other_geo)     { build_geo 640, 0, 320, 240 }
    let(:client)        { build_client }
    let(:other_client)  { build_client }
    subject(:tag)       { described_class.new('1', geo) }

    describe '.new' do
      it 'raises error unless id converts to string' do
        expect { described_class.new(1, geo) }.to raise_error(ArgumentError)
      end
    end

    describe '#clients' do
      it 'returns all clients contained in assigned columns' do
        tag.columns << Column.new(tag.geo)
        tag.current_column << client << other_client
        expect(tag.clients).to eq [client, other_client]
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
