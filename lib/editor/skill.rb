# frozen_string_literal: true

#--------------------------------------------------------------------------
# * Skill editor
#--------------------------------------------------------------------------

module Editor
  class Skill < Data
    SKILL_CONTROLS = {
      group_box: {
        skill: { label: 'Skill', x: 0.085, y: 0.01, width: 0.914, height: 0.98 },
        general: { label: 'General', x: 0.090, y: 0.12 },
        using_message: { label: 'Using Message', x: 0.27, y: 0.36, width: 0.24, height: 0.14 },
        required_weapon: { label: 'Required Weapon', x: 0.090, y: 0.60, height: 0.10 }
      },
      button: {
        casts: { label: '"casts *!"', tooltip: 'Automatically makes the message', x: 0.28, y: 0.46, width: 0.065 },
        does: { label: '"does *!"', tooltip: 'Automatically makes the message', x: 0.358, y: 0.46, width: 0.065 },
        uses: { label: '"uses *!"', tooltip: 'Automatically makes the message', x: 0.435, y: 0.46, width: 0.065 }
      },
      text_box: {
        message2: { label: 'Message 2', tooltip: 'Fixed phrase displayed as a message when using the skill in battle',
                    accessor: true, length: 999_999_999, x: 0.33, y: 0.42, width: 0.17 },
        message1: { label: 'Message 1', tooltip: 'Fixed phrase displayed as a message when using the skill in battle',
                    accessor: true, length: 999_999_999, x: 0.33, y: 0.38, width: 0.17 },
        description: { label: 'Description', accessor: true, length: 999_999_999, x: 0.15, y: 0.07, width: 0.65 },
        name: { label: 'Name', accessor: true, length: 999_999_999, x: 0.15, y: 0.03 }
      },
      value_box: {
        tp_cost: { label: 'TP', accessor: true, min: 0, max: 999_999_999, x: 0.15, y: 0.22, width: 0.03 },
        mp_cost: { label: 'MP', accessor: true, min: 0, max: 999_999_999, x: 0.15, y: 0.18, width: 0.03 }
      },
      combo_box: {
        required_wtype_id2: { label: 'Type 2', text: "None;#{$data_system.weapon_types.reject(&:empty?).join(';')}",
                              accessor: true, x: 0.15, y: 0.66 },
        required_wtype_id1: { label: 'Type 1', text: "None;#{$data_system.weapon_types.reject(&:empty?).join(';')}",
                              accessor: true, x: 0.15, y: 0.62 }
      },
      dropdown_box: {
        stype_id: { label: 'Skill Type', text: "None;#{$data_system.skill_types.reject(&:empty?).join(';')}",
                    accessor: true, x: 0.15, y: 0.14 },
        occasion: { label: 'Occasion', tooltip: 'Test', text: 'Always;Battle;Menu;Never', accessor: true, x: 0.15,
                    y: 0.30 },
        scope: { label: 'Scope',
                 text: 'None;One Enemy;All Enemies;1 Random Enemy;2 Random Enemy;3 Random Enemy;4 Random Enemy;One Ally;All Allies;One Ally (Dead);All Allies (Dead);The User', accessor: true, x: 0.15, y: 0.26 }
      }
    }

    def initialize
      super
      initialize_properties(SKILL_CONTROLS)
      @effects = Effects.new(@item)
      @damage = Damage.new(@item)
      @invocation = Invocation.new(@item)
    end

    def update(dt)
      super
      update_group(dt)
      update_group_item
      update_messages
    end

    def draw
      super
      @invocation.draw
      @results = recursive_draw_control(SKILL_CONTROLS, @item)
      @damage.draw
      @effects.draw
    end

    def update_group(dt)
      [@effects, @damage, @invocation].each { |c| c.update(dt) }
    end

    def update_group_item
      [@effects, @damage, @invocation].each { |c| c.item = @item }
    end

    def update_messages
      (@results || []).each do |entry|
        set_message(entry[:key]) if %i[casts does uses].include?(entry[:key])
      end
    end

    def set_message(symbol)
      label = SKILL_CONTROLS[:button][symbol][:label]
      message = label.gsub('*', @item.name).gsub('"', '')
      @item.message1 = message
    end
  end
end

#--------------------------------------------------------------------------
# * Skill Points (Limited Usage Skills) plugin
#--------------------------------------------------------------------------

# Create the new accessors
module RPG
  class Skill < RPG::UsableItem
    attr_accessor :total_charges

    alias esc_alias_initialize initialize
    def initialize
      esc_alias_initialize
      @total_charges = 5
    end
  end
end

module Editor
  # Update existing items
  class Data < Base
    alias esc_alias_initialize_items initialize_items
    def initialize_items
      esc_alias_initialize_items
      return unless Editor.current?(:skill)

      @items.each do |item|
        safe_attribute(item, :total_charges, 5)
      end
    end
  end

  # Draw the controls for the new accessors
  class Skill < Data
    SKILL_CONTROLS[:value_box][:tp_cost] =
      { label: 'TP', label_beside: true, accessor: true, min: 0, max: 999_999_999, x: 0.22, y: 0.18, width: 0.03 }
    SKILL_CONTROLS[:value_box][:total_charges] =
      { label: 'Charges', accessor: true, min: 0, max: 100, x: 0.15, y: 0.22, width: 0.03 }
  end
end

#--------------------------------------------------------------------------
# * Plugin: Extra Auto Messages (Auto Rows of 3)
#--------------------------------------------------------------------------

module Editor
  class Skill < Data
    EXTRA_MESSAGES = {
      strikes: '"strikes *!"',
      fires: '"fires *!"',
      summons: '"summons *!"',
      unleashes: '"unleashes *!"',
      flees: '"flees"'
    }

    BUTTON_LAYOUT = {
      x: 0.28, y: 0.50, width: 0.065, dx: 0.078, dy: 0.04, per_row: 3
    }

    # Adjust group box height
    rows = (EXTRA_MESSAGES.size + BUTTON_LAYOUT[:per_row] - 1) / BUTTON_LAYOUT[:per_row]
    SKILL_CONTROLS[:group_box][:using_message][:height] = 0.14 + rows * BUTTON_LAYOUT[:dy]

    # Generate buttons
    EXTRA_MESSAGES.each_with_index do |(key, label), i|
      r, c = i.divmod(BUTTON_LAYOUT[:per_row])
      SKILL_CONTROLS[:button][key] = {
        label:, tooltip: 'Automatically makes the message',
        x: BUTTON_LAYOUT[:x] + c * BUTTON_LAYOUT[:dx],
        y: BUTTON_LAYOUT[:y] + r * BUTTON_LAYOUT[:dy],
        width: BUTTON_LAYOUT[:width]
      }
    end

    alias plugin_update_messages update_messages
    def update_messages
      plugin_update_messages
      @results&.each { |e| set_message(e[:key]) if EXTRA_MESSAGES.key?(e[:key]) }
    end
  end
end
