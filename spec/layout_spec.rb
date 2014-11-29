require 'layout'

module Holo
  describe Layout do
    let(:geo)           { Geo.new(0, 0, 640, 480) }
    let(:client)        { instance_spy WM::Client }
    let(:other_client)  { instance_spy WM::Client }
    subject(:layout)    { described_class.new }

    before { layout.screens = { 0 => geo, 1 => geo } }

    describe '#screens=' do
      it 'assigns given screens as Screen objects in a Container' do
        expect(layout.screens.entries).to eq [
          Layout::Screen.new(0, geo),
          Layout::Screen.new(1, geo),
        ]
      end
    end

    describe '#<<' do
      before do
        layout << other_client
        layout << client
      end

      it 'adds given client to current col' do
        expect(layout.current_col).to include client
      end

      it 'sets given client as the current one in current col' do
        expect(layout.current_col.current_client).to be client
      end

      it 'moveresizes given client' do
        expect(client).to have_received :moveresize
      end

      it 'shows given client' do
        expect(client).to have_received :show
      end

      it 'focuses given client' do
        expect(client).to have_received :focus
      end

      it 'returns self' do
        expect(layout << client).to be layout
      end
    end

    describe '#remove' do
      before do
        layout << other_client
        layout << client
      end

      it 'removes given client from current col' do
        layout.remove client
        expect(layout.current_col).not_to include client
      end

      it 'assigns a new current client' do
        layout.remove client
        expect(layout.current_client).to be
      end

      it 'focus the new current client' do
        expect(other_client).to receive :focus
        layout.remove client
      end
    end

    describe '#suggest_geo_for' do
      it 'returns current col suggested geo' do
        expect(layout.suggest_geo_for :window)
          .to eq layout.current_col.suggest_geo_for :window
      end
    end

    describe 'handle_screen_sel' do
      it 'selects consecutive screen in given direction' do
        expect { layout.handle_screen_sel :next }
          .to change { layout.current_screen.id }.from(0).to(1)
      end

      it 'focus current client' do
        layout << client
        expect(client).to receive :focus
        2.times { layout.handle_screen_sel :next }
      end
    end

    describe 'handle_client_sel' do
      before do
        layout << client
        layout << other_client
      end

      it 'selects current col consecutive client in given direction' do
        expect { layout.handle_client_sel :pred }
          .to change { layout.current_client }.from(other_client).to(client)
      end

      it 'focuses current client' do
        expect(client).to receive :focus
        layout.handle_client_sel :pred
      end
    end

    describe 'handle_client_swap' do
      before do
        layout << other_client
        layout << client
      end

      it 'swaps current client with the other client' do
        layout.handle_client_swap :pred
        expect(layout.current_col.clients.entries).to eq [client, other_client]
      end

      it 'does not change current client' do
        expect { layout.handle_client_swap :pred }
          .not_to change { layout.current_client }
      end
    end

    describe 'handle_client_col_set' do
      before { layout << other_client << client }

      it 'sends :set! message to Col with current tag cols and direction' do
        expect(Layout::Col)
          .to receive(:set!).with layout.current_tag.cols, :next
        layout.handle_client_col_set :next
      end

      it 'sends :arrange! message to Col with current tag cols' do
        expect(Layout::Col).to receive(:arrange!)
          .with layout.current_tag.cols, layout.current_tag.geo
        layout.handle_client_col_set :next
      end

      it 'moveresizes current tag clients' do
        layout.current_tag.clients.each do |client|
          expect(client).to receive :moveresize
        end
        layout.handle_client_col_set :next
      end

      it 'does not change current client' do
        expect { layout.handle_client_col_set :next }
          .not_to change { layout.current_client }
      end
    end

    describe 'handle_kill_current' do
      before do
        layout << client
        layout.handle_kill_current
      end

      it 'kills current_client' do
        expect(client).to have_received :kill
      end
    end
  end
end
