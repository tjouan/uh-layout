require 'layout/container'

module Holo
  describe Layout::Container do
    subject(:container) { described_class.new %i[foo bar] }

    describe '#current' do
      it 'returns the first entry by default' do
        expect(container.current).to eq :foo
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
