module Uh
  class Layout
    describe Tag do
      let(:geo)           { build_geo }
      let(:other_geo)     { build_geo 640, 0, 320, 240 }
      let(:client)        { build_client }
      let(:other_client)  { build_client }
      let(:column)        { Column.new(geo) }
      subject(:tag)       { described_class.new '1', geo }

      describe '.new' do
        it 'raises error unless id converts to string' do
          expect { described_class.new 1, geo }.to raise_error(ArgumentError)
        end
      end

      describe '#clients' do
        it 'returns all clients contained in assigned columns' do
          tag.columns << column.tap { |column| column << client << other_client }
          expect(tag.clients).to eq [client, other_client]
        end
      end

      describe '#include?' do
        it 'returns false when tag does not include given client' do
          expect(tag.include? client).to be false
        end

        it 'returns true when tag includes given client' do
          tag.columns << column.tap { |column| column << client }
          expect(tag.include? client).to be true
        end
      end

      describe '#current_column_or_create' do
        context 'when tag has no column' do
          it 'creates a new column' do
            expect { tag.current_column_or_create }
              .to change { tag.columns.size }.from(0).to(1)
          end

          it 'returns the new column' do
            expect(tag.current_column_or_create).to be tag.columns.fetch 0
          end
        end

        context 'when tag has a column' do
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

      describe '#arranger' do
        it 'returns a fixed width arranger' do
          expect(tag.arranger).to be_an Arrangers::FixedWidth
        end
      end

      describe '#arrange_columns' do
        before { tag.columns << column }

        it 'purges empty columns' do
          tag.arrange_columns
          expect(tag.columns).to be_empty
        end

        it 'arranges columns' do
          arranger = instance_spy Arrangers::FixedWidth
          allow(tag).to receive(:arranger) { arranger }
          expect(arranger).to receive :arrange
          tag.arrange_columns
        end

        it 'arranges columns clients' do
          column << client
          expect(column).to receive :arrange_clients
          tag.arrange_columns
        end
      end
    end
  end
end
