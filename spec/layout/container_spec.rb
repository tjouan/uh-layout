require 'layout/container'

module Holo
  describe Layout::Container do
    subject(:container) { described_class.new %i[foo bar] }

    describe '#initialize' do
      it 'assigns no entries when no arguments are given' do
        expect(described_class.new).to be_empty
      end
    end

    describe '#current' do
      context 'when container has multiple entries' do
        it 'returns the first entry' do
          expect(container.current).to eq :foo
        end
      end

      context 'when container has no entry' do
        subject(:container) { described_class.new }

        it 'returns nil' do
          expect(container.current).to be nil
        end
      end
    end

    describe '#sel' do
      it 'sets consecutive entry in given direction as the current one' do
        container.sel :next
        expect(container.current).to eq :bar
      end
    end
  end
end
