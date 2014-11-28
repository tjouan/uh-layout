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

    describe '#==' do
      it 'equals another col with same geo' do
        expect(col).to eq described_class.new(geo)
      end

      it 'does not equal another col with different geo' do
        expect(col).not_to eq described_class.new(other_geo)
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
