module Editor
  class Features < Base
    attr_accessor :item

    FEATURES_CONTROLS = {
      group_box: {
        features: { label: 'Features', x: 0.52, y: 0.36, width: 0.280, height: 0.62 }
      },
      value_box: {
        features_value: { label: 'Value', min: 0, max: 100, x: 0.76, y: 0.90, width: 0.03 }
      },
      value_box_float: {
        features_value: { label: 'Value', text_value: '', x: 0.76, y: 0.90, width: 0.03 }
      },
      list_view: {
        features: { label: '', x: 0.62, y: 0.42, height: 0.47 },
        features_new: { label: '', x: 0.53, y: 0.38, height: 0.59 },
        features_data_id: { label: '', x: 0.71, y: 0.42, height: 0.47 }
      },
      button: {
        kind: { label: 'Kind', x: 0.62, y: 0.38 },
        content: { label: 'Content', x: 0.71, y: 0.38 },
        features_new: { label: 'New', x: 0.62, y: 0.90 },
        features_remove: { label: 'Delete', x: 0.62, y: 0.94 }
      }
    }

    CODE = {
      11 => "Element Rate",
      12 => "Debuff Rate",
      13 => "State Rate",
      14 => "State Resist",
      15 => "Death State", # Custom
      16 => "Element Absorption", # MV Trinity
      17 => "Element Reflection", # MV Trinity
      21 => "Parameter",
      22 => "Ex-Parameter",
      23 => "Sp-Parameter",
      31 => "Attack Element",
      32 => "Attack State",
      33 => "Attack Speed",
      34 => "Attack Times+",
      35 => "Attack Skill", # MZ
      36 => "Guard Skill", # Custom
      41 => "Add Skill Type",
      42 => "Seal Skill Type",
      43 => "Add Skill",
      44 => "Seal Skill",
      51 => "Equip Weapon",
      52 => "Equip Armor",
      53 => "Lock Equip",
      54 => "Seal Equip",
      55 => "Slot Type",
      61 => "Action Times+",
      62 => "Special Flag",
      63 => "Collapse Effect",
      64 => "Party Ability",
      65 => "Passive State" # MV Trinity
    }.freeze

    def initialize(item)
      super
      @item = item
      @display = []
      initialize_properties(FEATURES_CONTROLS)
    end

    def update(dt)
      super
      @display = @item.features.map do |features|
        CODE[features.code] || "Unknown Feature"
      end
    end

    def draw
      super
      draw_control(:group_box, :features)
      draw_control(:list_view, :features, special_value: @display)
      action_feature_delete if draw_control(:button, :features_remove)
      action_feature_new if draw_control(:button, :features_new)
      case current_code
      when 11 # Element Rate
        draw_control(:list_view, :features_data_id, accessor: @item, special_value: ["None"] + $data_system.elements.reject(&:empty?), index: features_list_index)
        draw_control(:value_box, :features_value, accessor: @item, index: features_list_index)
      when 12, 21 # Debuff Rate/Parameter
        draw_control(:list_view, :features_data_id, accessor: @item, special_value: $data_system.terms.params, index: features_list_index)
        draw_control(:value_box, :features_value, accessor: @item, index: features_list_index)
      when 13, 32 # State Rate/Attack State
        draw_control(:list_view, :features_data_id, accessor: @item, special_value: ["Normal Attack"] + $data_states.compact.map(&:name), index: features_list_index)
        draw_control(:value_box, :features_value, accessor: @item, index: features_list_index)
      when 14, 15 # State Resist
        draw_control(:list_view, :features_data_id, accessor: @item, special_value: ["Normal Attack"] + $data_states.compact.map(&:name), index: features_list_index)
      when 22 # Ex-Parameter
        draw_control(:list_view, :features_data_id, accessor: @item, special_value: ["HIT", "EVA", 'CRI', 'CEV', 'MEV', 'MRF', 'CNT', 'HRG', 'MRG', 'TRG'], index: features_list_index)
        draw_control(:value_box, :features_value, accessor: @item, index: features_list_index)
      when 23 # Sp-Parameter
        draw_control(:list_view, :features_data_id, accessor: @item, special_value: ['TGR', 'GRD', 'REC', 'PHA', 'MCR', 'TCR', 'PDR', 'MDR', 'FDR', 'EXR'], index: features_list_index)
        draw_control(:value_box, :features_value, accessor: @item, index: features_list_index)
      when 31 # Attack Element
        draw_control(:list_view, :features_data_id, accessor: @item, special_value: ["None"] + $data_system.elements.reject(&:empty?), index: features_list_index)
      when 33, 34, 61 # Attack Speed/Attack Times+/Action Times+
        draw_control(:value_box, :features_value, accessor: @item, index: features_list_index)
      when 41, 42 # Add Skill Type/Seal Skill Type
        draw_control(:list_view, :features_data_id, accessor: @item, special_value: ["None"] + $data_system.skill_types.reject(&:empty?), index: features_list_index)
      when 35, 36, 43, 44 # Attack Skill/Guard Skill/Add Skill/Seal Skill
        draw_control(:list_view, :features_data_id, accessor: @item, special_value: ["None"] + $data_skills.compact.map(&:name), index: features_list_index)
      when 51 # Equip Weapon
        draw_control(:list_view, :features_data_id, accessor: @item, special_value: ["None"] + $data_system.weapon_types.reject(&:empty?), index: features_list_index)
      when 52 # Equip Armor
        draw_control(:list_view, :features_data_id, accessor: @item, special_value: ["None"] + $data_system.armor_types.reject(&:empty?), index: features_list_index)
      when 53, 54 # Lock Equip/Seal Equip
        draw_control(:list_view, :features_data_id, accessor: @item, special_value: ["Weapon", "Shield", 'Head', 'Body', 'Accessory'], index: features_list_index)
      when 55 # Slot Type
        draw_control(:list_view, :features_data_id, accessor: @item, special_value: ["None", "Dual Wield"], index: features_list_index)
      when 62 # Special Flag
        draw_control(:list_view, :features_data_id, accessor: @item, special_value: ["Auto Battle", "Guard", 'Substitute', 'Preserve TP'], index: features_list_index)
      when 63 # Collapse Effect
        draw_control(:list_view, :features_data_id, accessor: @item, special_value: ['None', "Boss", "Instant", 'Not Disappear'], index: features_list_index)
      when 64 # Party Ability
        draw_control(:list_view, :features_data_id, accessor: @item, special_value: ["Encounter Half", "Encounter None", 'Cancel Surprise', 'Raise Preemptive', 'Gold Double', 'Drop Item Double'], index: features_list_index)
      end
      draw_control(:list_view, :features_new, special_value: CODE.values)
      draw_control(:button, :kind)
      draw_control(:button, :content)
    end

    def current_code
      return if @item.features.empty? || @item.features[features_list_index].nil?

      @item.features[features_list_index].code
    end

    def features_list_index
      FEATURES_CONTROLS[:list_view][:features][:value_index]
    end

    def action_feature_new
      #save_item_state(@undo_stack)
      @item.features << RPG::BaseItem::Feature.new(CODE.keys[FEATURES_CONTROLS[:list_view][:features_new][:value_index]])
      FEATURES_CONTROLS[:list_view][:features][:value_index] = @item.features.size - 1
      puts "INFO: Feature has been created. Click 'Save' to persist changes."
    end

    def action_feature_delete
      #save_item_state(@undo_stack)
      @item.features.delete_at(features_list_index)
      FEATURES_CONTROLS[:list_view][:features][:value_index] = [features_list_index - 1, 0].max
      puts "INFO: Feature has been deleted. Click 'Save' to persist changes."
    end
  end
end