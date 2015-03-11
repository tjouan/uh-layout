module Uh
  class Layout
    module Arrangers
      describe FixedWidth do
        class Entry
          include GeoAccessors

          def initialize(geo)
            @geo = geo
          end
        end

        let(:geo)           { build_geo 20, 0, 640, 480 }
        let(:entry)         { Entry.new(build_geo) }
        let(:entries)       { Container.new([entry, Entry.new(build_geo)]) }
        subject(:arranger)  { described_class.new(entries, geo, width: 300) }

        describe '#arrange' do
          it 'decreases first entry width as the optimal width' do
            arranger.arrange
            expect(entries[0].width).to eq 300
          end

          it 'offsets entries with given geo' do
            arranger.arrange
            expect(entries[0].x).to eq 20
          end

          it 'moves second entry aside the first entry' do
            arranger.arrange
            expect(entries[1].x).to eq 320
          end

          it 'increases last entry width to occupy remaining width' do
            arranger.arrange
            expect(entries[1].width).to eq 340
          end

          it 'copies given geo y' do
            entries[0].y = nil
            arranger.arrange
            expect(entries[0].y).to eq 0
          end

          it 'copies given geo height' do
            entries[0].height = nil
            arranger.arrange
            expect(entries[0].height).to eq 480
          end

          context 'without entry' do
            let(:entries) { Container.new([]) }

            it 'does not raise any error' do
              expect { arranger.arrange }.not_to raise_error
            end
          end
        end

        describe '#max_count?' do
          context 'when a new entry fits in current geo' do
            let(:entries) { Container.new([entry]) }

            it 'returns false' do
              expect(arranger.max_count?).to be false
            end
          end

          context 'when current geo can not contain more entry' do
            let(:entries) { Container.new([entry, entry.dup]) }

            it 'returns true' do
              expect(arranger.max_count?).to be true
            end
          end
        end
      end
    end
  end
end
