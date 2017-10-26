module Uh
  class Layout
    RSpec.describe Column do
      let(:geo)           { build_geo }
      let(:other_geo)     { build_geo 640, 0, 320, 240 }
      let(:mode)          { :stack }
      let(:client)        { build_client }
      let(:other_client)  { build_client }
      subject(:column)    { described_class.new geo, mode: mode }

      it 'has a copy to given geo' do
        expect(column.geo)
          .to eq(geo)
          .and not_be geo
      end

      it 'has no client assigned' do
        expect(column).to be_empty
      end

      it 'has :stack as default mode' do
        expect(column.mode).to be :stack
      end

      describe '#<<' do
        before { column << client }

        it 'adds given client' do
          expect(column.clients).to include client
        end

        it 'adds given client after current one' do
          column << other_client
          column.current_client = client
          column << new_client = build_client
          expect(column.clients.to_a).to eq [client, new_client, other_client]
        end

        it 'assigns column geo copy to given client' do
          expect(client.geo)
            .to eq(column.geo)
            .and not_be column.geo
        end

        it 'returns self' do
          expect(column << client).to be column
        end
      end

      describe '#mode_toggle' do
        it 'toggles mode from stack to tile' do
          expect { column.mode_toggle }
            .to change { column.mode }
            .from(:stack)
            .to :tile
        end

        it 'toggles mode from tile to stack' do
          column.mode_toggle
          expect { column.mode_toggle }
            .to change { column.mode }
            .from(:tile)
            .to :stack
        end

      end

      describe '#arranger' do
        context 'when column mode is stack' do
          it 'returns a stack arranger' do
            expect(column.arranger).to be_an Arrangers::Stack
          end
        end

        context 'when column mode is tile' do
          it 'returns a vertical tile arranger' do
            column.mode_toggle
            expect(column.arranger).to be_an Arrangers::VertTile
          end
        end
      end

      describe '#client_swap' do
        before { column << client << other_client }

        it 'sends #set message to clients with given direction' do
          expect(column.clients).to receive(:set).with :pred
          column.client_swap :pred
        end

        context 'when column mode is tile' do
          let(:mode) { :tile }

          it 'arranges current column clients' do
            expect(column).to receive :arrange_clients
            column.client_swap :pred
          end

          it 'shows and hides clients in current column' do
            expect(column).to receive :show_hide_clients
            column.client_swap :pred
          end
        end
      end

      describe '#arrange_clients' do
        before { column << client << other_client }

        it 'arranges clients' do
          arranger = instance_spy Arrangers::Stack
          allow(column).to receive(:arranger) { arranger }
          expect(arranger).to receive :arrange
          column.arrange_clients
        end

        it 'moveresizes clients' do
          expect([client, other_client]).to all receive :moveresize
          column.arrange_clients
        end
      end

      describe '#show_hide_clients' do
        let :arranger do
          double 'arranger', each_visible: nil, each_hidden: nil
        end

        it 'shows visible clients when they are hidden' do
          allow(arranger)
            .to receive(:each_visible)
            .and_yield(client.hide)
            .and_yield other_client.show
          expect(client).to receive :show
          expect(other_client).not_to receive :show
          column.show_hide_clients arranger: arranger
        end

        it 'hides hidden clients except those already hidden' do
          allow(arranger)
            .to receive(:each_hidden)
            .and_yield(client.show)
            .and_yield other_client.hide
          expect(client).to receive :hide
          expect(other_client).not_to receive :hide
          column.show_hide_clients arranger: arranger
        end
      end
    end
  end
end
