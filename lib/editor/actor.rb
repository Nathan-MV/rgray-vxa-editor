# frozen_string_literal: true

#--------------------------------------------------------------------------
# * Actor editor
#--------------------------------------------------------------------------

module Editor
  class Actor < Data
    ACTOR_CONTROLS = {
      group_box: {
        actors: { label: 'Actors', x: 0.085, y: 0.01, width: 0.914, height: 0.98 },
        general: { label: 'General', x: 0.090, y: 0.12 },
        graphic: { label: 'Graphic', x: 0.27, y: 0.12, width: 0.53 },
        starting_equipment: { label: 'Starting Equipment', x: 0.090, y: 0.36, width: 0.418, height: 0.62 }
      },
      text_box: {
        name: { label: 'Name', length: 999_999_999, x: 0.15, y: 0.03 },
        description: { label: 'Description', length: 999_999_999, x: 0.15, y: 0.07, width: 0.65 },
        nickname: { label: 'Nickname', length: 999_999_999, x: 0.33, y: 0.03 }
      },
      combo_box: {
        class_id: { label: 'Class', x: 0.15, y: 0.14 }
      },
      value_box: {
        initial_level: { label: 'Initial Level', min: 1, max: 999_999_999, x: 0.15, y: 0.18 },
        max_level: { label: 'Max Level', min: 1, max: 999_999_999, x: 0.15, y: 0.22 }
      },
      list_view: {
        equips_weapon1: { label: '', x: 0.10, y: 0.38, width: 0.070, height: 0.59 },
        equips_weapon2: { label: '', x: 0.18, y: 0.38, width: 0.070, height: 0.59 },
        equips_shield: { label: '', x: 0.18, y: 0.38, width: 0.070, height: 0.59 },
        equips_head: { label: '', x: 0.26, y: 0.38, width: 0.070, height: 0.59 },
        equips_armor: { label: '', x: 0.34, y: 0.38, width: 0.070, height: 0.59 },
        equips_accessory: { label: '', x: 0.42, y: 0.38, width: 0.070, height: 0.59 }
      }
    }

    def initialize
      super
      @features = Features.new(@item)
      initialize_properties(ACTOR_CONTROLS)
      initialize_equips
    end

    def update(dt)
      super
      @features.update(dt)
      @features.item = @item
      update_equips
    end

    def draw
      super
      @features.draw
      %i[actors general graphic starting_equipment].each { |key| draw_control(:group_box, key) }
      %i[description name nickname].each { |key| draw_control(:text_box, key, accessor: @item) }
      draw_control(:combo_box, :class_id, accessor: @item,
                                          special_value: "None;#{$data_classes.compact.map(&:name).join(';')}")
      %i[max_level initial_level].each { |key| draw_control(:value_box, key, accessor: @item) }

      draw_control(:list_view, :equips_weapon1, accessor: @item, special_value: ['None'] + @equips_weapon1.map(&:name),
                                                items: $data_weapons, sort: @equips_weapon1, index: 0)
      draw_control(:list_view, :equips_shield, accessor: @item, special_value: ['None'] + @equips_shield.map(&:name),
                                               items: $data_armors, sort: @equips_shield, index: 1)
      draw_control(:list_view, :equips_head, accessor: @item, special_value: ['None'] + @equips_head.map(&:name),
                                             items: $data_armors, sort: @equips_head, index: 2)
      draw_control(:list_view, :equips_armor, accessor: @item, special_value: ['None'] + @equips_armor.map(&:name),
                                              items: $data_armors, sort: @equips_armor, index: 3)
      draw_control(:list_view, :equips_accessory, accessor: @item,
                                                  special_value: ['None'] + @equips_accessory.map(&:name), items: $data_armors, sort: @equips_accessory, index: 4)
    end

    private

    def initialize_equips
      %i[equips_weapon1 equips_shield equips_head equips_armor equips_accessory].each do |equip|
        instance_variable_set("@#{equip}", [])
      end
    end

    def update_equips
      %i[equips_weapon1 equips_shield equips_head equips_armor equips_accessory].each_with_index do |equip, index|
        instance_variable_set("@#{equip}", equip_options(index))
      end
    end

    def equip_options(index)
      case index
      when 0 then equip_data($data_weapons, 51, :wtype_id, :weapon)
      when 1..4 then equip_data($data_armors, 52, :atype_id, :armor, index)
      end
    end

    def equip_data(data, code, type_id, category, index = nil)
      data.compact.flat_map do |item|
        next unless item.etype_id == index || category == :weapon

        $data_classes[@item.class_id].features.select do |f|
          f.code == code && f.data_id == item.send(type_id)
        end.map { item }
      end.compact
    end
  end
end
