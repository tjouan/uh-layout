require 'layout'

class Layout
  # FIXME: add test for not adding more columns than can fit in geo
  describe Column::Arranger do
    let(:geo)           { Geo.new(0, 0, 640, 480) }
    let(:client)        { instance_spy WM::Client }
    let(:column)        { Column.new(geo) }
    let(:columns)       { Container.new([column]) }
    subject(:arranger)  { described_class.new columns, geo }

    describe '#move_current_client' do
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

      shared_examples 'does not change columns' do
        it 'does not change colums' do
          expect { arranger.move_current_client :succ }
            .not_to change { columns.entries }
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
        include_examples 'does not change columns'
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
          include_examples 'does not change columns'
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

    describe '#arrange' do
      let(:columns) { Container.new([column, Column.new(geo)]) }

      before do
        geo.x = 20
        arranger.arrange column_width: 300
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
