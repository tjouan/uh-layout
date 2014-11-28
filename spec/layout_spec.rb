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
