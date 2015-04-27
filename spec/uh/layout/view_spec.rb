module Uh
  class Layout
    RSpec.describe View do
      let(:geo)           { build_geo }
      let(:other_geo)     { build_geo 640, 0, 320, 240 }
      let(:client)        { build_client }
      let(:other_client)  { build_client }
      let(:column)        { Column.new(geo) }
      subject(:view)       { described_class.new '1', geo }

      describe '.new' do
        it 'raises error unless id converts to string' do
          expect { described_class.new 1, geo }
            .to raise_error(Layout::ArgumentError)
        end
      end

      describe '#clients' do
        it 'returns all clients contained in assigned columns' do
          view.columns << column.tap { |column| column << client << other_client }
          expect(view.clients).to eq [client, other_client]
        end
      end

      describe '#include?' do
        it 'returns false when view does not include given client' do
          expect(view.include? client).to be false
        end

        it 'returns true when view includes given client' do
          view.columns << column.tap { |column| column << client }
          expect(view.include? client).to be true
        end
      end

      describe '#current_column_or_create' do
        context 'when view has no column' do
          it 'creates a new column' do
            expect { view.current_column_or_create }
              .to change { view.columns.size }.from(0).to(1)
          end

          it 'returns the new column' do
            expect(view.current_column_or_create).to be view.columns.fetch 0
          end
        end

        context 'when view has a column' do
          before { view.columns << column }

          it 'does not create any column' do
            expect { view.current_column_or_create }
              .not_to change { view.columns.size }
          end

          it 'returns the current column' do
            expect(view.current_column_or_create).to be column
          end
        end
      end

      describe '#arranger' do
        it 'returns a fixed width arranger' do
          expect(view.arranger).to be_an Arrangers::FixedWidth
        end
      end

      describe '#arrange_columns' do
        before { view.columns << column }

        it 'purges empty columns' do
          view.arrange_columns
          expect(view.columns).to be_empty
        end

        it 'arranges columns' do
          arranger = instance_spy Arrangers::FixedWidth
          allow(view).to receive(:arranger) { arranger }
          expect(arranger).to receive :arrange
          view.arrange_columns
        end

        it 'arranges columns clients' do
          column << client
          expect(column).to receive :arrange_clients
          view.arrange_columns
        end
      end
    end
  end
end
