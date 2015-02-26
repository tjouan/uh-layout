require 'layout'

module Holo
  describe Layout do
    let(:geo)           { Geo.new(0, 0, 640, 480) }
    let(:client)        { instance_spy WM::Client }
    let(:other_client)  { instance_spy WM::Client }
    let(:widget)        { double('widget').as_null_object }
    subject(:layout)    { described_class.new }

    before { layout.screens = { 0 => geo, 1 => geo } }
    before { layout.widgets << widget }

    describe '#screens=' do
      it 'assigns given screens as Screen objects in a Container' do
        expect(layout.screens.entries).to match [
          an_object_having_attributes(id: 0, geo: geo),
          an_object_having_attributes(id: 1, geo: geo)
        ]
      end
    end

    describe '#<<' do
      before { layout << other_client << client }

      it 'adds given client to current column' do
        expect(layout.current_column).to include client
      end

      it 'sets given client as the current one in current column' do
        expect(layout.current_column.current_client).to be client
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

      it 'updates widgets' do
        expect(widget).to have_received(:update).exactly(2).times
      end

      it 'returns self' do
        expect(layout << client).to be layout
      end
    end

    describe '#remove' do
      before { layout << client << other_client }

      it 'removes given client from the layout' do
        layout.remove client
        expect(layout).not_to include client
      end

      it 'assigns a new current client' do
        layout.remove client
        expect(layout.current_client).to be
      end

      it 'focuses the new current client' do
        expect(other_client).to receive :focus
        layout.remove client
      end

      it 'redraws columns with an arranger' do
        expect_any_instance_of(Layout::Column::Arranger).to receive :redraw
        layout.remove client
      end

      it 'moveresizes remaining clients' do
        expect(other_client).to receive :moveresize
        layout.remove client
      end

      it 'updates widgets' do
        expect(widget).to receive :update
        layout.remove client
      end
    end

    describe '#include?' do
      it 'returns false when layout does not include given client' do
        expect(layout.include? client).to be false
      end

      it 'returns true when layout includes given client' do
        layout << client
        expect(layout.include? client).to be true
      end
    end

    describe '#arranger_for_current_tag' do
      it 'returns an arranger for current tag columns and geo' do
        expect(layout.arranger_for_current_tag)
          .to respond_to(:update_geos)
          .and have_attributes(
            columns:  layout.current_tag.columns,
            geo:      layout.current_tag.geo
          )
      end
    end

    describe '#suggest_geo_for' do
      it 'returns current tag suggested geo' do
        expect(layout.suggest_geo)
          .to eq layout.current_tag.suggest_geo
      end

      context 'when current tag has a column' do
        before { layout.current_tag.columns << Layout::Column.new(geo) }

        it 'returns current column suggested geo' do
          expect(layout.suggest_geo)
            .to eq layout.current_column.suggest_geo
        end
      end
    end

    describe 'handle_screen_sel' do
      it 'selects consecutive screen in given direction' do
        expect { layout.handle_screen_sel :succ }
          .to change { layout.current_screen.id }.from(0).to(1)
      end

      it 'focus selected screen current client' do
        layout << client
        expect(client).to receive :focus
        2.times { layout.handle_screen_sel :succ }
      end

      it 'updates widgets' do
        expect(widget).to receive :update
        layout.handle_screen_sel :succ
      end
    end

    describe 'handle_screen_set' do
      before { layout << client }

      it 'removes current client from origin screen' do
        layout.handle_screen_set :succ
        expect(layout.screens[0].tags.flat_map(&:clients)).not_to include client
      end

      it 'adds current client to consecutive screen in given direction' do
        layout.handle_screen_set :succ
        expect(layout.screens[1].tags.flat_map(&:clients)).to include client
      end

      it 'selects consecutive screen in given direction' do
        expect { layout.handle_screen_set :succ }
          .to change { layout.current_screen.id }.from(0).to(1)
      end

      context 'without client' do
        before { layout.remove client }

        it 'does not raise any error' do
          expect { layout.handle_screen_set :succ }.not_to raise_error
        end
      end
    end

    describe '#handle_column_sel' do
      context 'without client' do
        it 'does not raise any error' do
          expect { layout.handle_column_sel :succ }.not_to raise_error
        end
      end

      context 'with two clients in two columns' do
        before do
          layout << client
          layout.current_tag.columns << Layout::Column.new(geo).tap do |o|
            o << other_client
          end
        end

        it 'selects the column consecutive to current one in given direction' do
          layout.handle_column_sel :succ
          expect(layout.current_column).to be layout.current_tag.columns[1]
        end

        it 'focuses the current client of selected column' do
          expect(other_client).to receive :focus
          layout.handle_column_sel :succ
        end

        it 'updates widgets' do
          expect(widget).to receive :update
          layout.handle_column_sel :succ
        end
      end
    end

    describe '#handle_client_sel' do
      context 'without client' do
        it 'does not raise any error' do
          expect { layout.handle_client_sel :succ }.not_to raise_error
        end
      end

      context 'with one column and two clients' do
        before { layout << client << other_client }

        it 'selects current column consecutive client in given direction' do
          expect { layout.handle_client_sel :pred }
            .to change { layout.current_client }.from(other_client).to(client)
        end

        it 'focuses current client' do
          expect(client).to receive :focus
          layout.handle_client_sel :pred
        end

        it 'updates widgets' do
          expect(widget).to receive :update
          layout.handle_client_sel :pred
        end
      end
    end

    describe '#handle_client_swap' do
      context 'without client' do
        it 'does not raise any error' do
          expect { layout.handle_client_swap :pred }.not_to raise_error
        end
      end

      context 'with one column and two clients' do
        before { layout << other_client << client }

        it 'swaps current client with the other client' do
          layout.handle_client_swap :pred
          expect(layout.current_column.clients.entries)
            .to eq [client, other_client]
        end

        it 'does not change current client' do
          expect { layout.handle_client_swap :pred }
            .not_to change { layout.current_client }
        end

        it 'updates widgets' do
          expect(widget).to receive :update
          layout.handle_client_swap :pred
        end
      end
    end

    describe '#handle_client_column_set' do
      context 'without client' do
        it 'does not raise any error' do
          expect { layout.handle_client_column_set :succ }.not_to raise_error
        end
      end

      context 'with one column and two clients' do
        let(:arranger) { instance_spy Layout::Column::Arranger }

        before { layout << other_client << client }

        it 'moves current client with column arranger' do
          expect(arranger).to receive(:move_current_client).with(:succ)
          layout.handle_client_column_set :succ, arranger: arranger
        end

        it 'arranges columns with column arranger' do
          expect(arranger).to receive :update_geos
          layout.handle_client_column_set :succ, arranger: arranger
        end

        it 'moveresizes current tag clients' do
          layout.current_tag.clients.each do |client|
            expect(client).to receive :moveresize
          end
          layout.handle_client_column_set :succ
        end

        it 'does not change current client' do
          expect { layout.handle_client_column_set :succ }
            .not_to change { layout.current_client }
        end

        it 'updates widgets' do
          expect(widget).to receive :update
          layout.handle_client_column_set :succ
        end
      end
    end

    describe '#handle_kill_current' do
      context 'without client' do
        it 'does not raise any error' do
          expect { layout.handle_kill_current }.not_to raise_error
        end
      end

      context 'with a client' do
        before { layout << client }

        it 'kills current client' do
          layout.handle_kill_current
          expect(client).to have_received :kill
        end
      end
    end
  end
end
