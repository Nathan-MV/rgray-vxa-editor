module Editor
  class Note < Base
    attr_accessor :item

    NOTE_CONTROLS = {
      group_box: {
        note: { label: 'Note', x: 0.555, y: 0.34, width: 0.275, height: 0.64 }
      },
      text_box: {
        note: { label: '', length: 999_999_999, x: 0.565, y: 0.355, width: 0.255, height: 0.615 }
      }
    }

    def initialize(item)
      super
      @item = item
      initialize_properties(NOTE_CONTROLS)
    end

    def update(dt)
      super
    end

    def draw
      super
      draw_control(:group_box, :note)
      draw_control(:text_box, :note, accessor: @item)
    end
  end
end