module Uh
  class Layout
    RSpec.describe History do
      subject(:history) { described_class.new }

      it 'has an empty view history' do
        expect(history.views).to be_empty
      end

      describe '#record_view' do
        it 'adds current view' do
          history.record_view :some_view
          expect(history.views).to include :some_view
        end

        it 'limits stored views count to configured views size' do
          history.views_size_max.times { |n| history.record_view "view_#{n}" }
          expect { history.record_view :one_more }
            .not_to change { history.views.size }
        end
      end

      describe '#last_view' do
        it 'returns last recorded view' do
          history.record_view :view_1
          history.record_view :view_2
          expect(history.last_view).to be :view_2
        end
      end
    end
  end
end
