module Editor
  class Invocation < Base
    attr_accessor :item

    INVOCATION_CONTROLS = {
      group_box: {
        invocation: { label: 'Invocation', x: 0.090, y: 0.36 }
      },
      value_box: {
        repeats: { label: 'Repeats', min: 1, max: 9, x: 0.15, y: 0.46, width: 0.03 },
        speed: { label: 'Speed', min: 0, max: 2000, x: 0.15, y: 0.38, width: 0.03 },
        success_rate: { label: 'Success %', min: 0, max: 100, x: 0.15, y: 0.42, width: 0.03 }
      },
      combo_box: {
        animation_id: { label: 'Animation', x: 0.15, y: 0.54 }
      },
      dropdown_box: {
        hit_type: { label: 'Hit Type', text: 'Certain Hit;Physical Attack;Special Attack', x: 0.15, y: 0.50 }
      }
    }

    def initialize(item)
      super
      @item = item
      initialize_properties(INVOCATION_CONTROLS)
    end

    def update(dt)
      super
    end

    def draw
      super
      draw_control(:group_box, :invocation)
      draw_control(:combo_box, :animation_id, accessor: @item, special_value: 'None;' + $data_animations.compact.map(&:name).join(';'))
      draw_control(:dropdown_box, :hit_type, accessor: @item)
      draw_control(:value_box, :repeats, accessor: @item)
      draw_control(:value_box, :success_rate, accessor: @item, special_value: "%")
      draw_control(:value_box, :speed, accessor: @item)
    end
  end
end