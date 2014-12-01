require 'layout'

class Layout
  describe Column do
    RSpec::Matchers.define_negated_matcher :not_be, :be

    let(:geo)         { Geo.new(0, 0, 640, 480) }
    let(:other_geo)   { Geo.new(640, 0, 320, 240) }
    let(:client)      { instance_spy WM::Client }
    subject(:column)  { described_class.new(geo) }

    it 'has a copy to given geo' do
      expect(column.geo).to eq(geo).and not_be geo
    end

    it 'has no client assigned' do
      expect(column).to be_empty
    end

    describe '.set!' do
      let(:columns) { Container.new([column]) }

      shared_examples 'client move' do |expected_column_index = 1|
        it 'removes current client from origin column' do
          expect(column).not_to include client
        end

        it 'adds current client in a new column' do
          expect(columns[expected_column_index]).to include client
        end
      end

      shared_examples 'client stays current' do
        it 'preserves current client as the current one' do
          expect(columns.current.current_client).to be client
        end
      end

      shared_examples 'column no create' do |expected_size|
        it 'does not create a column' do
          expect(columns.size).to eq expected_size
        end
      end

      shared_examples 'columns update current' do |expected_current_column_index|
        it 'sets the destination column as the current one' do
          expect(columns.current).to be columns[expected_current_column_index]
        end
      end

      context 'when one column with one client is given' do
        before do
          column << client
          described_class.set! columns, :succ
        end

        include_examples 'client stays current'
        include_examples 'column no create', 1
      end

      context 'when one column with many clients is given' do
        before do
          column << client << client.dup
          described_class.set! columns, :succ
        end

        include_examples 'client move'
        include_examples 'client stays current'
        include_examples 'columns update current', 1
      end

      context 'when two columns are given' do
        let(:columns) { Container.new([column, described_class.new(geo)]) }

        before { columns[1] << client.dup }

        context 'when origin column has many clients' do
          before do
            column << client << client.dup
            described_class.set! columns, :succ
          end

          include_examples 'client move'
          include_examples 'client stays current'
          include_examples 'column no create', 2
          include_examples 'columns update current', 1
        end

        context 'when origin column has one client' do
          before do
            column << client
            described_class.set! columns, :succ
          end

          include_examples 'client move', 0
          include_examples 'client stays current'

          it 'purges the empty column' do
            expect(columns.size).to eq 1
          end
        end
      end
    end

    describe '.arrange!' do
      let(:columns) { Container.new([column, described_class.new(geo)]) }

      before do
        geo.x = 20
        described_class.arrange! columns, geo, column_width: 300
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

    describe '#current_client=' do
      it 'sets given client as the current one' do
        column << client
        column << instance_spy(WM::Client)
        column.current_client = client
        expect(column.current_client).to be client
      end
    end

    describe '#<<' do
      before { column << client }

      it 'assigns suggested geo to given client' do
        expect(client)
          .to have_received(:geo=).with(column.suggest_geo_for :window)
      end

      it 'adds given client' do
        expect(column.clients).to include client
      end

      it 'returns self' do
        expect(column << client).to be column
      end
    end

    describe '#remove' do
      before do
        column << client
        column.remove client
      end

      it 'removes given client' do
        expect(column).not_to include client
      end
    end

    describe '#suggest_geo_for' do
      it 'returns the assigned geo' do
        expect(column.suggest_geo_for :window).to eq geo
      end
    end
  end
end
