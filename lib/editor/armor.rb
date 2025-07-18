# frozen_string_literal: true

#--------------------------------------------------------------------------
# * Armor editor
#--------------------------------------------------------------------------

module Editor
  class Armor < Data
    ARMOR_CONTROLS = {
      group_box: {
        armors: { label: 'Armors', x: 0.085, y: 0.01, width: 0.914, height: 0.98 },
        general: { label: 'General', x: 0.090, y: 0.12 },
        learning: { label: 'Learning', x: 0.27, y: 0.36, width: 0.24, height: 0.62 }
      },
      text_box: {
        name: { label: 'Name', length: 999_999_999, x: 0.15, y: 0.03 },
        description: { label: 'Description', length: 999_999_999, x: 0.15, y: 0.07, width: 0.65 }
      },
      value_box: {
        price: { label: 'Price', min: 0, max: 999_999_999, x: 0.15, y: 0.18, width: 0.06 }
      },
      dropdown_box: {
        atype_id: { label: 'Armor Type', x: 0.15, y: 0.22 },
        etype_id: { label: 'Equip Type', text: 'Shield;Head;Body;Accessory', x: 0.15, y: 0.14 }
      }
    }

    def initialize
      super
      @features = Features.new(@item)
      @parameter = Parameter.new(@item)
      initialize_properties(ARMOR_CONTROLS)
    end

    def update(dt)
      super
      update_group(dt)
      update_group_item
    end

    def draw
      super
      @features.draw
      @parameter.draw
      %i[armors general].each { |key| draw_control(:group_box, key) }
      %i[description name].each { |key| draw_control(:text_box, key, accessor: @item) }
      draw_control(:dropdown_box, :atype_id, accessor: @item, special_value: $data_system.terms.etypes.join(';'))
      draw_control(:value_box, :price, accessor: @item)
      draw_control(:dropdown_box, :etype_id, accessor: @item)
    end

    private

    def update_group(dt)
      @features.update(dt)
      @parameter.update(dt)
    end

    def update_group_item
      @features.item = @item
      @parameter.item = @item
    end
  end
end
