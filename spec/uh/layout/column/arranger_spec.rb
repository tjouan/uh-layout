module Uh
  class Layout
    class Column
      describe Arranger do
        let(:geo)           { build_geo }
        let(:client)        { build_client }
        let(:column_width)  { 300 }
        let(:column)        { Column.new(geo) }
        let(:columns)       { Container.new([column]) }
        subject(:arranger)  { described_class.new columns, geo,
                                column_width: column_width }

        describe '#redraw' do
          it 'purges columns' do
            expect(arranger).to receive :purge
            arranger.redraw
          end

          it 'updates columns geo' do
            expect(arranger).to receive :update_geos
            arranger.redraw
          end

          it 'yields given block' do
            expect { |b| arranger.redraw &b }.to yield_control
          end
        end

        describe '#purge' do
          it 'removes empty columns' do
            arranger.purge
            expect(columns).to be_empty
          end
        end

        describe '#move_current_client' do
          shared_examples 'moves current client' do |expected_column_index|
            it 'removes current client from origin column' do
              arranger.move_current_client :succ
              expect(column).not_to include client
            end

            it 'adds current client in the destination column' do
              arranger.move_current_client :succ
              expect(columns[expected_column_index]).to include client
            end

            it 'updates destination column as the current one' do
              arranger.move_current_client :succ
              expect(columns.current).to be columns[expected_column_index]
            end

            it 'preserves current client as the current one' do
              expect { arranger.move_current_client :succ }
                .not_to change { columns.current.current_client }
            end

            it 'does not leave empty columns' do
              expect(columns.none? &:empty?).to be true
            end
          end

          it 'returns self' do
            expect(arranger.move_current_client :succ).to be arranger
          end

          context 'given one column with one client' do
            before { column << client }

            include_examples 'moves current client', 0
          end

          context 'given one column with many clients' do
            before { column << client << client.dup }

            include_examples 'moves current client', 1
          end

          context 'given two columns' do
            let(:columns) { Container.new([column, Column.new(geo)]) }

            before { columns[1] << client.dup }

            context 'when origin column has many clients' do
              before { column << client << client.dup }

              include_examples 'moves current client', 1
            end

            context 'when origin column has one client' do
              before { column << client }

              include_examples 'moves current client', 0
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

              it 'appends a new column' do
                expect(arranger.get_or_create_column :succ).to be columns[2]
              end

              it 'prepends a new column' do
                columns.current = columns[0]
                expect(arranger.get_or_create_column :pred).to be columns[0]
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

        describe '#update_geos' do
          let(:columns) { Container.new([column, Column.new(geo)]) }

          before { geo.x = 20 }

          it 'decreases first column width as the optimal column width' do
            arranger.update_geos
            expect(columns[0].width).to eq 300
          end

          it 'offsets each column with given geo' do
            arranger.update_geos
            expect(columns[0].x).to eq 20
          end

          it 'moves second column aside the first column' do
            arranger.update_geos
            expect(columns[1].x).to eq 320
          end

          it 'increases last column width to occupy remaining width' do
            arranger.update_geos
            expect(columns[1].width).to eq 340
          end

          context 'without columns' do
            let(:columns) { Container.new([]) }

            it 'does not raise any error' do
              expect { arranger.update_geos }.not_to raise_error
            end
          end
        end
      end
    end
  end
end