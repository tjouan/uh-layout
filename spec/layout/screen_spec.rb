require 'layout'

class Layout
  describe Screen do
    let(:geo)         { Geo.new(0, 0, 640, 480) }
    let(:other_geo)   { Geo.new(640, 0, 320, 240) }
    subject(:screen)  { described_class.new(0, geo) }

    it 'has one default tag with id 1 assigned' do
      expect(screen.tags).to include an_object_having_attributes(id: 1)
    end
  end
end
