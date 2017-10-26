module Uh
  class Layout
    module Arrangers
      RSpec.describe VertTile do
        let(:entry)         { build_entry }
        let(:other_entry)   { build_entry }
        let(:entries)       { Container.new [entry, other_entry] }
        let(:geo)           { build_geo 0, 0, 300, 480 }
        subject(:arranger)  { described_class.new entries, geo }

        describe '#arrange' do
          it 'sets x offset from given geo on all entries' do
            arranger.arrange
            expect(entries.map &:x).to all eq 0
          end

          it 'sets width from given geo on all entries' do
            arranger.arrange
            expect(entries.map &:width).to all eq 300
          end

          it 'splits entries height equally' do
            arranger.arrange
            expect(entries.map &:height).to all eq 239
          end

          it 'adds a margin between entries' do
            arranger.arrange
            expect(entries[1].y - entries[0].height - entries[0].y).to eq 1
          end
        end

        describe '#each_visible' do
          it 'yields all entries' do
            expect { |b| arranger.each_visible &b }
              .to yield_successive_args entry, other_entry
          end
        end

        describe '#each_hidden' do
          it 'yields no entry' do
            expect { |b| arranger.each_hidden &b }.not_to yield_control
          end
        end
      end
    end
  end
end

