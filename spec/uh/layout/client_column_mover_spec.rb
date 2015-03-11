module Uh
  class Layout
    describe ClientColumnMover do
      let(:client)            { build_client }
      let(:column)            { Column.new(build_geo) }
      let(:columns)           { Container.new([column]) }
      let(:columns_max_count) { false }
      subject(:mover)         { described_class.new columns, columns_max_count }

      describe '#move_current' do
        shared_examples 'moves current client' do |expected_column_index|
          it 'removes current client from origin column' do
            mover.move_current :succ
            expect(column).not_to include client
          end

          it 'adds current client in the destination column' do
            mover.move_current :succ
            expect(columns[expected_column_index]).to include client
          end

          it 'updates destination column as the current one' do
            mover.move_current :succ
            expect(columns.current).to be columns[expected_column_index]
          end

          it 'preserves current client as the current one' do
            expect { mover.move_current :succ }
              .not_to change { columns.current.current_client }
          end
        end

        context 'given one column with one client' do
          before { column << client }

          include_examples 'moves current client', 1
        end

        context 'given one column with many clients' do
          before { column << client << client.dup }

          include_examples 'moves current client', 1
        end

        context 'given two columns' do
          let(:columns) { Container.new([column, Column.new(build_geo)]) }

          before { columns[1] << client.dup }

          context 'when origin column has many clients' do
            before { column << client << client.dup }

            include_examples 'moves current client', 1
          end

          context 'when origin column has one client' do
            before { column << client }

            include_examples 'moves current client', 1
          end
        end
      end

      describe '#get_or_create_column' do
        let(:columns) { Container.new([column, Column.new(build_geo)]) }

        it 'returns the consecutive column in given direction' do
          expect(mover.get_or_create_column :succ).to be columns[1]
        end

        context 'when current column is last in given direction' do
          before { columns.current = columns[1] }

          context 'when max columns count is not reached' do
            it 'appends a new column' do
              expect(mover.get_or_create_column :succ).to be columns[2]
            end

            it 'prepends a new column' do
              columns.current = columns[0]
              expect(mover.get_or_create_column :pred).to be columns[0]
            end
          end

          context 'when max columns count is reached' do
            let(:columns_max_count) { true }

            it 'returns the consecutive column in given direction' do
              expect(mover.get_or_create_column :succ).to be columns[0]
            end
          end
        end
      end
    end
  end
end
