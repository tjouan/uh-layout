require 'layout/container'

describe Layout::Container do
  let(:entries)       { %i[foo bar] }
  subject(:container) { described_class.new entries }

  describe '#initialize' do
    it 'assigns no entries when no arguments are given' do
      expect(described_class.new).to be_empty
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
      it 'does not change current entry' do
        expect { container.current = :baz }.not_to change { container.current }
      end
    end
  end

  describe '#<<' do
    it 'adds given entry' do
      container << :baz
      expect(container).to include :baz
    end
  end

  describe '#remove' do
    it 'removes given argument from entries' do
      expect(container.remove :foo).not_to include :foo
    end

    context 'when given entry is the current one' do
      before { container.current = :bar }

      it 'assigns previous entry as the current one' do
        container.remove :bar
        expect(container.current).to be :foo
      end
    end

    context 'when given entry is the last one' do
      let(:entries) { [:foo] }

      it 'has no more current entry' do
        container.remove :foo
        expect(container.current).to be nil
      end
    end
  end

  describe '#sel' do
    it 'sets consecutive entry in given direction as the current one' do
      container.sel :next
      expect(container.current).to be :bar
    end
  end
end
