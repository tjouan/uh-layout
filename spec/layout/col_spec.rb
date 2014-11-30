require 'layout'

class Layout
  describe Col do
    RSpec::Matchers.define_negated_matcher :not_be, :be

    let(:geo)       { Geo.new(0, 0, 640, 480) }
    let(:other_geo) { Geo.new(640, 0, 320, 240) }
    let(:client)    { instance_spy WM::Client }
    subject(:col)   { described_class.new(geo) }

    it 'has a copy to given geo' do
      expect(col.geo).to eq(geo).and not_be geo
    end

    it 'has no client assigned' do
      expect(col).to be_empty
    end

    describe '.set!' do
      let(:cols) { Container.new([col]) }

      shared_examples 'client move' do |expected_col_index = 1|
        it 'removes current client from origin col' do
          expect(col).not_to include client
        end

        it 'adds current client in a new col' do
          expect(cols[expected_col_index]).to include client
        end
      end

      shared_examples 'client stays current' do
        it 'preserves current client as the current one' do
          expect(cols.current.current_client).to be client
        end
      end

      shared_examples 'col no create' do |expected_size|
        it 'does not create a col' do
          expect(cols.size).to eq expected_size
        end
      end

      shared_examples 'cols update current' do |expected_current_col_index|
        it 'sets the destination col as the current one' do
          expect(cols.current).to be cols[expected_current_col_index]
        end
      end

      context 'when one col with one client is given' do
        before do
          col << client
          described_class.set! cols, :succ
        end

        include_examples 'client stays current'
        include_examples 'col no create', 1
      end

      context 'when one col with many clients is given' do
        before do
          col << client << client.dup
          described_class.set! cols, :succ
        end

        include_examples 'client move'
        include_examples 'client stays current'
        include_examples 'cols update current', 1
      end

      context 'when two cols are given' do
        let(:cols) { Container.new([col, described_class.new(geo)]) }

        before { cols[1] << client.dup }

        context 'when origin col has many clients' do
          before do
            col << client << client.dup
            described_class.set! cols, :succ
          end

          include_examples 'client move'
          include_examples 'client stays current'
          include_examples 'col no create', 2
          include_examples 'cols update current', 1
        end

        context 'when origin col has one client' do
          before do
            col << client
            described_class.set! cols, :succ
          end

          include_examples 'client move', 0
          include_examples 'client stays current'

          it 'purges the empty col' do
            expect(cols.size).to eq 1
          end
        end
      end
    end

    describe '.arrange!' do
      let(:cols) { Container.new([col, described_class.new(geo)]) }

      before do
        geo.x = 20
        described_class.arrange! cols, geo, col_width: 300
      end

      it 'decreases first col width as the optimal col width' do
        expect(cols[0].geo.width).to eq 300
      end

      it 'offsets each col with given geo' do
        expect(cols[0].geo.x).to eq 20
      end

      it 'moves second col aside the first col' do
        expect(cols[1].geo.x).to eq 320
      end

      it 'increases last col width to occupy remaining width' do
        expect(cols[1].geo.width).to eq 320
      end

    end

    describe '#current_client=' do
      it 'sets given client as the current one' do
        col << client
        col << instance_spy(WM::Client)
        col.current_client = client
        expect(col.current_client).to be client
      end
    end

    describe '#<<' do
      before { col << client }

      it 'assigns suggested geo to given client' do
        expect(client).to have_received(:geo=).with(col.suggest_geo_for :window)
      end

      it 'adds given client' do
        expect(col.clients).to include client
      end

      it 'returns self' do
        expect(col << client).to be col
      end
    end

    describe '#remove' do
      before do
        col << client
        col.remove client
      end

      it 'removes given client' do
        expect(col).not_to include client
      end
    end

    describe '#suggest_geo_for' do
      it 'returns the assigned geo' do
        expect(col.suggest_geo_for :window).to eq geo
      end
    end
  end
end
