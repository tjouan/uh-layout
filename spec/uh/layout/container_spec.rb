module Uh
  class Layout
    RSpec.describe Container do
      let(:entries)       { %i[foo bar] }
      subject(:container) { described_class.new entries }

      describe '#initialize' do
        it 'assigns no entries when no arguments are given' do
          expect(described_class.new).to be_empty
        end
      end

      describe '#to_ary' do
        it 'supports implicit conversion to array' do
          expect([] + container).to eq %i[foo bar]
        end
      end

      describe '#current' do
        context 'when container has multiple entries' do
          it 'returns the first entry' do
            expect(container.current).to be :foo
          end
        end

        context 'when container has no entry' do
          subject(:container) { described_class.new }

          it 'returns nil' do
            expect(container.current).to be nil
          end
        end
      end

      describe '#current=' do
        context 'when given argument is an entry' do
          before { container.current = :bar }

          it 'assigns given entry as the current one' do
            expect(container.current).to be :bar
          end
        end

        context 'when given argument is not an entry' do
          it 'raises ArgumentError' do
            expect { container.current = :unknown_entry }
              .to raise_error Layout::ArgumentError
          end
        end
      end

      describe '#<<' do
        it 'adds given entry' do
          container << :baz
          expect(container).to include :baz
        end
      end

      describe '#insert_after_current' do
        it 'inserts given entry after current one' do
          container.insert_after_current :baz
          expect(container.entries).to eq %i[foo baz bar]
        end

        context 'when container has no entry' do
          let(:entries) { [] }

          it 'raises a RuntimeError' do
            expect { container.insert_after_current :foo }
              .to raise_error Layout::RuntimeError
          end
        end
      end

      describe '#remove' do
        let(:entries) { %i[foo bar baz] }

        before { container.current = :bar }

        it 'removes given argument from entries' do
          container.remove :foo
          expect(container).not_to include :foo
        end

        it 'preserves the current entry' do
          container.remove :foo
          expect(container.current).to be :bar
        end

        it 'returns self' do
          expect(container.remove :foo).to be container
        end

        it 'raises an ArgumentError when given entry is not included' do
          expect { container.remove :unknown_entry }.to raise_error ArgumentError
        end

        context 'when the first and current entry is removed' do
          before do
            container.current = :foo
            container.remove :foo
          end

          it 'assigns next entry as the current one' do
            expect(container.current).to be :bar
          end
        end

        context 'when given entry is the only one' do
          let(:entries) { [:bar] }

          it 'has no more current entry' do
            container.remove :bar
            expect(container.current).to be nil
          end
        end
      end

      describe '#remove_if' do
        it 'removes entries for which given block returns true' do
          container.remove_if { |e| e == :foo }
          expect(container).not_to include :foo
        end
      end

      describe '#get' do
        it 'returns consecutive entry in given direction' do
          expect(container.get :succ).to be :bar
        end

        it 'returns nil when no consecutive entry exists' do
          expect(container.get :pred).to be nil
        end

        context 'with cycle option' do
          it 'returns consecutive entry, cycling before first one' do
            expect(container.get :pred, cycle: true).to be :bar
          end

          it 'returns consecutive entry, cycling after last one' do
            container.current = :bar
            expect(container.get :succ, cycle: true).to be :foo
          end
        end
      end

      describe '#sel' do
        it 'sets consecutive entry in given direction as the current one' do
          container.sel :next
          expect(container.current).to be :bar
        end
      end

      describe '#set' do
        let(:entries) { %i[foo bar baz] }

        it 'swaps current entry with consecutive one in given direction' do
          container.set :next
          expect(container.entries).to eq %i[bar foo baz]
        end

        it 'does not change current entry' do
          expect { container.set :next }.not_to change { container.current }
        end

        context 'when direction is out of range' do
          it 'rotates the entries' do
            container.set :pred
            expect(container.entries).to eq %i[bar baz foo]
          end

          it 'does not change current entry' do
            expect { container.set :pred }.not_to change { container.current }
          end
        end

        context 'when entries count is less than 2' do
          let(:entries) { %i[foo] }

          it 'raises a RuntimeError' do
            expect { container.set :pred }.to raise_error Layout::RuntimeError
          end
        end
      end

      describe '#swap' do
        it 'swaps entries matched by given indexes' do
          container.swap 0, 1
          expect(container.entries).to eq %i[bar foo]
        end
      end
    end
  end
end
