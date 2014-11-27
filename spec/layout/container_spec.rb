require 'layout/container'

module Holo
  describe Layout::Container do
    subject(:container) { described_class.new %i[foo bar] }

    describe '#current' do
      it 'returns the first entry by default' do
        expect(container.current).to eq :foo
      end
    end
  end
end
