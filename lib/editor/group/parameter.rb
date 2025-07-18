# frozen_string_literal: true

module Editor
  class Parameter < Base
    attr_accessor :item

    PARAMETER_CONTROLS = {
      group_box: {
        parameter: { label: 'Parameter', x: 0.27, y: 0.12, width: 0.53 }
      },
      value_box: {
        params_7: { label: 'LUK', min: 1, max: 999_999_999, x: 0.73, y: 0.18 },
        params_6: { label: 'AGI', min: 1, max: 999_999_999, x: 0.60, y: 0.18 },
        params_5: { label: 'MDF', min: 1, max: 999_999_999, x: 0.47, y: 0.18 },
        params_4: { label: 'MAT', min: 1, max: 999_999_999, x: 0.33, y: 0.18 },
        params_3: { label: 'DEF', min: 1, max: 999_999_999, x: 0.73, y: 0.14 },
        params_2: { label: 'ATK', min: 1, max: 999_999_999, x: 0.60, y: 0.14 },
        params_1: { label: 'MMP', min: 1, max: 999_999_999, x: 0.47, y: 0.14 },
        params_0: { label: 'MHP', min: 1, max: 999_999_999, x: 0.33, y: 0.14 }
      }
    }

    def initialize(item)
      super
      @item = item
      initialize_properties(PARAMETER_CONTROLS)
    end

    def draw
      super
      draw_control(:group_box, :parameter)
      PARAMETER_CONTROLS[:value_box].each_key { |key| draw_control(:value_box, key, accessor: @item) }
    end
  end
end
