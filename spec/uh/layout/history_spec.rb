module Uh
  class Layout
    describe History do
      subject(:history) { described_class.new }

      it 'has an empty tag history' do
        expect(history.tags).to be_empty
      end

      describe '#record_tag' do
        it 'adds current tag' do
          history.record_tag :some_tag
          expect(history.tags).to include :some_tag
        end

        it 'limits stored tags count to configured tags size' do
          history.tags_size_max.times { |n| history.record_tag "tag_#{n}" }
          expect { history.record_tag :one_more }
            .not_to change { history.tags.size }
        end
      end

      describe '#last_tag' do
        it 'returns last recorded tag' do
          history.record_tag :tag_1
          history.record_tag :tag_2
          expect(history.last_tag).to be :tag_2
        end
      end
    end
  end
end
