module Editor
  class Effects < Base
    attr_accessor :item

    # EFFECTS_CONTROLS = {
    #   group_box: {
    #     effects: { label: 'Effects', x: 0.27, y: 0.34, width: 0.275, height: 0.64 }
    #   },
    #   text_box: {
    #     effects_condition: { label: 'Condition', x: 0.51, y: 0.94, width: 0.03 }
    #   },
    #   value_box: {
    #     effects_value1: { label: 'Value %', min: 0, max: 100, x: 0.51, y: 0.86, width: 0.03 },
    #     effects_value2: { label: '+ Value', min: 0, max: 999_999, x: 0.51, y: 0.90, width: 0.03 }
    #   },
    #   list_view: {
    #     effects: { label: '', x: 0.37, y: 0.36, height: 0.535 },
    #     effects_new: { label: '', x: 0.28, y: 0.36, height: 0.61 },
    #     effects_data_id: { label: 'Data ID', x: 0.46, y: 0.36, height: 0.495   }
    #   },
    #   button: {
    #     effects_new: { label: 'New', x: 0.37, y: 0.90 },
    #     effects_remove: { label: 'Delete', x: 0.37, y: 0.94 }
    #   },
    # }

    EFFECTS_CONTROLS = {
      group_box: {
        effects: { label: 'Effects', x: 0.52, y: 0.36, width: 0.280, height: 0.62 }
      },
      text_box: {
        effects_condition: { label: 'Condition', x: 0.76, y: 0.94, width: 0.03 }
      },
      value_box: {
        effects_value1: { label: 'Value %', min: 0, max: 100, x: 0.76, y: 0.90, width: 0.03 },
        effects_value2: { label: '+ Value', min: 0, max: 999_999, x: 0.76, y: 0.94, width: 0.03 }
      },
      value_box_float: {
        effects_value1: { label: 'Value', text_value: '', x: 0.76, y: 0.90, width: 0.03 }
      },
      list_view: {
        effects: { label: '', x: 0.62, y: 0.42, height: 0.47 },
        effects_new: { label: '', x: 0.53, y: 0.38, height: 0.59 },
        effects_data_id: { label: '', x: 0.71, y: 0.42, height: 0.47 }
      },
      button: {
        kind: { label: 'Kind', tooltip: 'Something', x: 0.62, y: 0.38 },
        content: { label: 'Content', x: 0.71, y: 0.38 },
        effects_new: { label: 'New', x: 0.62, y: 0.90 },
        effects_remove: { label: 'Delete', x: 0.62, y: 0.94 }
      },
    }

    CODE = {
      11 => "Recover HP",
      12 => "Recover MP",
      13 => "Gain TP",
      14 => "Gain Skill Total Charges",
      15 => "Gain Skill Charges",
      21 => "Add State",
      22 => "Remove State",
      31 => "Add Buff",
      32 => "Add Debuff",
      33 => "Remove Buff",
      34 => "Remove Debuff",
      41 => "Special Effect",
      42 => "Grow",
      43 => "Learn Skill",
      44 => "Common Event",
      45 => "Passive State", # MV Trinity
      46 => "Enable Switch", # Custom
      47 => "Disable Switch" # Custom
    }.freeze

    def initialize(item)
      super
      @item = item
      @display = []
      initialize_properties(EFFECTS_CONTROLS)
    end

    def update(dt)
      super
      @display = @item.effects.map do |effect|
        CODE[effect.code] || "Unknown Effect"
      end
    end

    def draw
      super
      draw_control(:group_box, :effects)
      draw_control(:list_view, :effects, special_value: @display)
      action_effect_delete if draw_control(:button, :effects_remove)
      action_effect_new if draw_control(:button, :effects_new)
      case current_code
      when 11, 12
        draw_control(:value_box, :effects_value1, accessor: @item, index: effects_list_index)
        draw_control(:value_box, :effects_value2, accessor: @item, index: effects_list_index)
        #draw_control(:text_box, :effects_condition, accessor: @item, index: effects_list_index)
      when 13, 14, 15
        draw_control(:value_box, :effects_value1, accessor: @item, index: effects_list_index)
        #draw_control(:text_box, :effects_condition, accessor: @item, index: effects_list_index)
      when 21, 22
        draw_control(:value_box, :effects_value1, accessor: @item, index: effects_list_index)
        draw_control(:list_view, :effects_data_id, accessor: @item, special_value: ["Normal Attack"] + $data_states.compact.map(&:name), index: effects_list_index)
        #draw_control(:text_box, :effects_condition, accessor: @item, index: effects_list_index)
      when 31, 32, 42
        draw_control(:value_box, :effects_value1, accessor: @item, index: effects_list_index)
        draw_control(:list_view, :effects_data_id, accessor: @item, special_value: $data_system.terms.params, index: effects_list_index)
        #draw_control(:text_box, :effects_condition, accessor: @item, index: effects_list_index)
      when 33, 34
        draw_control(:list_view, :effects_data_id, accessor: @item, special_value: $data_system.terms.params, index: effects_list_index)
        #draw_control(:text_box, :effects_condition, accessor: @item, index: effects_list_index)
      when 43
        draw_control(:list_view, :effects_data_id, accessor: @item, special_value: ["Attack"] + $data_skills.compact.map(&:name), index: effects_list_index)
        #draw_control(:text_box, :effects_condition, accessor: @item, index: effects_list_index)
      when 44
        draw_control(:list_view, :effects_data_id, accessor: @item, special_value: ["None"] + $data_common_events.compact.map(&:name), index: effects_list_index)
        #draw_control(:text_box, :effects_condition, accessor: @item, index: effects_list_index)
      when 46, 47
        draw_control(:list_view, :effects_data_id, accessor: @item, special_value: ["None"] + $data_system.switches.compact, index: effects_list_index)
        #draw_control(:text_box, :effects_condition, accessor: @item, index: effects_list_index)
      end
      draw_control(:list_view, :effects_new, special_value: CODE.values)
      draw_control(:button, :kind)
      draw_control(:button, :content)
    end

    def current_code
      return if @item.effects.empty? || @item.effects[effects_list_index].nil?

      @item.effects[effects_list_index].code
    end

    def effects_list_index
      EFFECTS_CONTROLS[:list_view][:effects][:value_index]
    end

    def action_effect_new
      #save_item_state(@undo_stack)
      @item.effects << RPG::UsableItem::Effect.new(CODE.keys[EFFECTS_CONTROLS[:list_view][:effects_new][:value_index]])
      EFFECTS_CONTROLS[:list_view][:effects][:value_index] = @item.effects.size - 1
      puts "INFO: Effect has been created. Click 'Save' to persist changes."
    end

    def action_effect_delete
      #save_item_state(@undo_stack)
      @item.effects.delete_at(effects_list_index)
      EFFECTS_CONTROLS[:list_view][:effects][:value_index] = [effects_list_index - 1, 0].max
      puts "INFO: Effect has been deleted. Click 'Save' to persist changes."
    end
  end
end