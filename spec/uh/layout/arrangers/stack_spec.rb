module Uh
  class Layout
    module Arrangers
      describe Stack do
        let(:entry)         { build_entry }
        let(:other_entry)   { build_entry }
        let(:entries)       { Container.new([entry, other_entry]) }
        let(:geo)           { build_geo 0, 0, 300, 480 }
        subject(:arranger)  { described_class.new entries, geo }

        describe '#arrange' do
          it 'sets given geo on all entries' do
            arranger.arrange
            expect(entries.map(&:geo)).to all eq geo
          end
        end

        describe '#each_visible' do
          it 'yields current entry' do
            expect { |b| arranger.each_visible &b }
              .to yield_successive_args entry
          end

          context 'with no current entry' do
            let(:entries) { Container.new([]) }

            it 'does not yield' do
              expect { |b| arranger.each_visible &b }.not_to yield_control
            end
          end
        end

        describe '#each_hidden' do
          it 'yields all entries except current one' do
            expect { |b| arranger.each_hidden &b }
              .to yield_successive_args other_entry
          end
        end
      end
    end
  end
end
