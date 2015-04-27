module Uh
  RSpec.describe Layout do
    let(:geo)           { build_geo }
    let(:client)        { build_client }
    let(:other_client)  { build_client }
    let(:widget)        { double('widget').as_null_object }
    let(:options)       { { } }
    subject(:layout)    { described_class.new options }

    before do
      layout.screens << Layout::Screen.new(0, geo)
      layout.screens << Layout::Screen.new(1, geo)
      layout.widgets << widget
    end

    context 'when given colors option' do
      let(:options) { { colors: { fg: 'rgb:42/42/42' } } }

      it 'merges given colors with default ones' do
        expect(layout.colors).to include fg: 'rgb:42/42/42', bg: 'rgb:0c/0c/0c'
      end
    end

    describe '#register' do
      it 'uses a registrant to register the layout with given display' do
        display = double 'display'
        expect(Layout::Registrant).to receive(:register).with layout, display
        layout.register display
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

    describe '#update_widgets' do
      it 'updates widgets' do
        expect(layout.widgets).to all receive :update
        layout.update_widgets
      end

      it 'redraws widgets' do
        expect(layout.widgets).to all receive :redraw
        layout.update_widgets
      end
    end

    describe '#suggest_geo' do
      it 'returns current view geo copy' do
        expect(layout.suggest_geo)
          .to eq(layout.current_view.geo)
          .and not_be layout.current_view.geo
      end

      context 'when current view has a column' do
        before { layout.current_view.columns << Layout::Column.new(build_geo 42) }

        it 'returns current column geo' do
          expect(layout.suggest_geo)
            .to eq(layout.current_column.geo)
            .and not_be layout.current_column.geo
        end
      end
    end

    describe '#<<' do
      before { layout << other_client }

      it 'adds given client to current column' do
        layout << client
        expect(layout.current_column).to include client
      end

      it 'sets given client as the current one in current column' do
        layout << client
        expect(layout.current_column.current_client).to be client
      end

      it 'arranges current column clients' do
        expect(layout.current_column).to receive :arrange_clients
        layout << client
      end

      it 'shows and hides clients in current column' do
        expect(layout.current_column).to receive :show_hide_clients
        layout << client
      end

      it 'focuses given client' do
        expect(client).to receive :focus
        layout << client
      end

      it 'updates widgets' do
        expect(widget).to receive :update
        layout << client
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

      it 'arranges columns in removed client view' do
        expect(layout.current_view).to receive :arrange_columns
        layout.remove client
      end

      it 'shows and hides clients in removed client column' do
        expect(layout.current_column).to receive :show_hide_clients
        layout.remove client
      end

      it 'focuses the new current client' do
        expect(other_client).to receive :focus
        layout.remove client
      end

      it 'updates widgets' do
        expect(widget).to receive :update
        layout.remove client
      end
    end

    describe '#update' do
      context 'when given client is visible' do
        before { client.show }

        it 'updates the widgets' do
          expect(layout).to receive :update_widgets
          layout.update client
        end
      end

      context 'when client is hidden' do
        before { client.hide }

        it 'does not update the widget' do
          expect(layout).not_to receive :update_widgets
          layout.update client
        end
      end
    end

    describe '#expose' do
      it 'updates the widgets' do
        expect(layout).to receive :update_widgets
        layout.expose :window
      end
    end

    describe '#handle_screen_sel' do
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

    describe '#handle_screen_set' do
      before { layout << client }

      it 'removes current client from origin screen' do
        layout.handle_screen_set :succ
        expect(layout.screens[0].views.flat_map(&:clients)).not_to include client
      end

      it 'adds current client to consecutive screen in given direction' do
        layout.handle_screen_set :succ
        expect(layout.screens[1].views.flat_map(&:clients)).to include client
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

    describe '#handle_view_sel' do
      before { layout << client }

      it 'hides clients on previously selected view' do
        layout.handle_view_sel '2'
        expect(client).to be_hidden
      end

      it 'sets the selected view as the current one' do
        layout.handle_view_sel '2'
        expect(layout.current_view.id).to eq '2'
      end

      it 'shows and hides clients in selected view columns' do
        layout.handle_view_sel '2'
        expect(layout.current_screen.views[0].columns)
          .to all receive :show_hide_clients
        layout.handle_view_sel '1'
      end

      it 'focuses selected view current client' do
        layout.handle_view_sel '2'
        expect(client).to receive :focus
        layout.handle_view_sel '1'
      end

      it 'updates widgets' do
        expect(widget).to receive :update
        layout.handle_view_sel '2'
      end

      it 'accepts non-string arguments' do
        layout.handle_view_sel 2
        expect(layout.current_view.id).to eq '2'
      end

      it 'records previous view in history' do
        previous_view = layout.current_view
        layout.handle_view_sel 2
        expect(layout.history.views).to include previous_view
      end
    end

    describe '#handle_view_set' do
      context 'without client' do
        it 'does not raise any error' do
          expect { layout.handle_view_set '2' }.not_to raise_error
        end
      end

      context 'with a client' do
        before { layout << other_client << client }

        it 'removes current client from origin view' do
          origin_view = layout.current_view
          layout.handle_view_set '2'
          expect(origin_view).not_to include client
        end

        it 'removes current client from layout' do
          expect(layout).to receive(:remove).with client
          layout.handle_view_set '2'
        end

        it 'hides current client' do
          expect(client).to receive :hide
          layout.handle_view_set '2'
        end

        it 'adds current client to given view' do
          layout.handle_view_set '2'
          dest_view = layout.current_screen.views.find { |e| e.id == '2' }
          expect(dest_view).to include client
        end

        it 'preserves current view' do
          layout.handle_view_set '2'
          expect(layout.current_view.id).to eq '1'
        end

        it 'updates widgets' do
          expect(widget).to receive :update
          layout.handle_view_set '2'
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
          layout.current_view.columns << Layout::Column.new(geo).tap do |o|
            o << other_client
          end
        end

        it 'selects the column consecutive to current one in given direction' do
          layout.handle_column_sel :succ
          expect(layout.current_column).to be layout.current_view.columns[1]
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

    describe '#handle_column_mode_toggle' do
      context 'without column' do
        it 'does not raise any error' do
          expect { layout.handle_column_mode_toggle }.not_to raise_error
        end
      end

      context 'with a column' do
        before { layout << client }

        it 'toggles current column mode' do
          expect(layout.current_column).to receive :mode_toggle
          layout.handle_column_mode_toggle
        end

        it 'arranges current column clients' do
          expect(layout.current_column).to receive :arrange_clients
          layout.handle_column_mode_toggle
        end

        it 'shows and hides clients in current column' do
          expect(layout.current_column).to receive :show_hide_clients
          layout.handle_column_mode_toggle
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

        it 'updates column clients visibility' do
          expect(layout.current_column).to receive :show_hide_clients
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
        before { layout << client }

        it 'does not raise any error' do
          expect { layout.handle_client_swap :pred }.not_to raise_error
        end
      end

      context 'with one column and two clients' do
        before { layout << other_client << client }

        it 'sends #client_swap to current column with given direction' do
          expect(layout.current_column).to receive(:client_swap).with :pred
          layout.handle_client_swap :pred
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
        let(:mover) { instance_spy Layout::ClientColumnMover }

        before { layout << other_client << client }

        it 'moves current client with given client column mover' do
          expect(mover).to receive(:move_current).with(:succ)
          layout.handle_client_column_set :succ, mover: mover
        end

        it 'arranges current view columns' do
          expect(layout.current_view).to receive :arrange_columns
          layout.handle_client_column_set :succ
        end

        it 'shows and hides clients in selected view columns' do
          expect(layout.current_view.columns).to all receive :show_hide_clients
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

    describe '#handle_history_view_pred' do
      it 'selects last view recorded in history' do
        layout.handle_view_sel 2
        expect { layout.handle_history_view_pred }
          .to change { layout.current_view.id }
          .from(?2).to ?1
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
          expect(client).to receive :kill
          layout.handle_kill_current
        end
      end
    end
  end
end
