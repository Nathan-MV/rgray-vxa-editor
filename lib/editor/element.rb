# frozen_string_literal: true

module Editor
  class Element < Data
    ELEMENT_CONTROLS = {
      group_box: {
        element: { label: 'Element', x: 0.085, y: 0.01, width: 0.914, height: 0.98 }
      },
      dropdown_box: {
        immunities: { x: 155, y: 85, width: 100, height: 20 },
        resistances: { x: 155, y: 60, width: 100, height: 20 },
        weaknesses: { x: 155, y: 35, width: 100, height: 20 }
      }
    }

    def initialize
      super
      initialize_properties(ELEMENT_CONTROLS)
    end

    def draw
      super
      [:element].each { |key| draw_control(:group_box, key) }
      [:immunities, :resistances, :weaknesses].each { |key| draw_control(:dropdown_box, key, accessor: @item, special_value: "None" + $data_system.elements.compact.join(';')) }
    end
  end
end
