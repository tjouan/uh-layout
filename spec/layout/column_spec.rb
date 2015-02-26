require 'layout'

class Layout
  describe Column do
    RSpec::Matchers.define_negated_matcher :not_be, :be

    let(:geo)         { Holo::Geo.new(0, 0, 640, 480) }
    let(:other_geo)   { Holo::Geo.new(640, 0, 320, 240) }
    let(:client)      { Holo::WM::Client.new(instance_spy Holo::Window) }
    subject(:column)  { described_class.new(geo) }

    it 'has a copy to given geo' do
      expect(column.geo).to eq(geo).and not_be geo
    end

    it 'has no client assigned' do
      expect(column).to be_empty
    end

    describe '#<<' do
      before { column << client }

      it 'assigns suggested geo to given client' do
        expect(client.geo).to eq column.suggest_geo
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

    describe '#suggest_geo' do
      it 'returns the assigned geo' do
        expect(column.suggest_geo).to eq geo
      end
    end
  end
end
