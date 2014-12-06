require 'layout'

class Layout
  # FIXME: add test for not adding more columns than can fit in geo
  describe Column::Arranger do
    let(:geo)           { Geo.new(0, 0, 640, 480) }
    let(:client)        { instance_spy WM::Client }
    let(:column_width)  { 300 }
    let(:column)        { Column.new(geo) }
    let(:columns)       { Container.new([column]) }
    subject(:arranger)  { described_class.new columns, geo,
                            column_width: column_width }

    describe '#move_current_client' do
      # FIXME: we should define *all* shared examples in only one definition,
      # and call this in every context.
      # it should always be the same, we can test that we add in the candidate
      # column, we can compare indexes where destination client is.
      # for columns count maybe we can pass as parameter
      shared_examples 'moves client' do |expected_column_index = 1|
        it 'removes current client from origin column' do
          arranger.move_current_client :succ
          expect(column).not_to include client
        end

        it 'adds current client in the next column' do
          arranger.move_current_client :succ
          expect(columns[expected_column_index]).to include client
        end
      end

      shared_examples 'preserves current client' do
        it 'preserves current client as the current one' do
          expect(columns.current.current_client).to be client
        end
      end

      shared_examples 'does not change columns count' do
        it 'does not change colums' do
          expect { arranger.move_current_client :succ }
            .not_to change { columns.size }
        end
      end

      shared_examples 'updates current column' do |expected_current_column_index = 1|
        it 'sets the destination column as the current one' do
          arranger.move_current_client :succ
          expect(columns.current).to be columns[expected_current_column_index]
        end
      end

      it 'returns self' do
        expect(arranger.move_current_client :succ).to be arranger
      end

      context 'given one column with one client' do
        before { column << client }

        include_examples 'preserves current client'
        include_examples 'does not change columns count'
      end

      context 'given one column with many clients' do
        before { column << client << client.dup }

        include_examples 'moves client'
        include_examples 'preserves current client'
        include_examples 'updates current column'
      end

      context 'given two columns' do
        let(:columns) { Container.new([column, Column.new(geo)]) }

        before { columns[1] << client.dup }

        context 'when origin column has many clients' do
          before { column << client << client.dup }

          include_examples 'moves client'
          include_examples 'preserves current client'
          include_examples 'does not change columns count'
          include_examples 'updates current column'
        end

        context 'when origin column has one client' do
          before { column << client }

          include_examples 'moves client', 0
          include_examples 'preserves current client'

          it 'purges the empty column' do
            arranger.move_current_client :succ
            expect(columns.size).to eq 1
          end
        end
      end
    end

    describe '#get_or_create_column' do
      let(:columns) { Container.new([column, Column.new(geo)]) }

      it 'returns the consecutive column in given direction' do
        expect(arranger.get_or_create_column :succ).to be columns[1]
      end

      context 'when current column is last in given direction' do
        before { columns.current = columns[1] }

        context 'when max columns count is not reached' do
          before { geo.width = 4096 }

          it 'creates a new column' do
            expect(arranger.get_or_create_column :succ).to be columns[2]
          end
        end

        context 'when max columns count is reached' do
          it 'returns the consecutive column in given direction' do
            expect(arranger.get_or_create_column :succ).to be columns[0]
          end
        end
      end
    end

    describe '#max_columns_count?' do
      context 'when a new column fits in current geo' do
        it 'returns false' do
          expect(arranger.max_columns_count?).to be false
        end
      end

      context 'when current geo can not contain more column' do
        let(:columns) { Container.new([column, Column.new(geo)]) }

        it 'returns true' do
          expect(arranger.max_columns_count?).to be true
        end
      end
    end

    describe '#arrange' do
      let(:columns) { Container.new([column, Column.new(geo)]) }

      before do
        geo.x = 20
        arranger.arrange
      end

      it 'decreases first column width as the optimal column width' do
        expect(columns[0].geo.width).to eq 300
      end

      it 'offsets each column with given geo' do
        expect(columns[0].geo.x).to eq 20
      end

      it 'moves second column aside the first column' do
        expect(columns[1].geo.x).to eq 320
      end

      it 'increases last column width to occupy remaining width' do
        expect(columns[1].geo.width).to eq 320
      end
    end
  end
end
