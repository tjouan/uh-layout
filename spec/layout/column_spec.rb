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

      it 'assigns column geo to given client' do
        expect(client.geo).to eq column.geo
      end

      it 'adds given client' do
        expect(column.clients).to include client
      end

      it 'returns self' do
        expect(column << client).to be column
      end
    end

    describe '#update_clients_visibility' do
      let(:other_client) { Holo::WM::Client.new(instance_spy Holo::Window) }

      before { column << client.show << other_client.show }

      it 'hides clients except the current one' do
        expect(other_client).to receive :hide
        expect(client).not_to receive :hide
        column.update_clients_visibility
      end

      it 'shows current client' do
        expect(client).to receive :show
        column.update_clients_visibility
      end
    end
  end
end
