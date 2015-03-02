require 'layout'

class Layout
  describe Column do
    let(:geo)           { build_geo }
    let(:other_geo)     { build_geo 640, 0, 320, 240 }
    let(:client)        { build_client }
    let(:other_client)  { build_client }
    subject(:column)    { described_class.new(geo) }

    it 'has a copy to given geo' do
      expect(column.geo).to eq(geo).and not_be geo
    end

    it 'has no client assigned' do
      expect(column).to be_empty
    end

    describe '#<<' do
      before { column << client }

      it 'assigns column geo copy to given client' do
        expect(client.geo).to eq(column.geo).and not_be column.geo
      end

      it 'adds given client' do
        expect(column.clients).to include client
      end

      it 'returns self' do
        expect(column << client).to be column
      end
    end

    describe '#arrange_clients' do
      before { column << client << other_client }

      it 'updates clients geometries' do
        column.width = 320
        column.arrange_clients
        expect(column.clients.map(&:geo)).to all eq column.geo
      end

      it 'moveresizes clients' do
        expect([client, other_client]).to all receive :moveresize
        column.arrange_clients
      end
    end

    describe '#show_hide_clients' do
      let(:other_client) { build_client }

      before { column << client.show << other_client.show }

      it 'hides clients except the current one' do
        expect(other_client).to receive :hide
        expect(client).not_to receive :hide
        column.show_hide_clients
      end

      it 'shows current client' do
        expect(client).to receive :show
        column.show_hide_clients
      end
    end
  end
end
