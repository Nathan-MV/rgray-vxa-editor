# frozen_string_literal: true

#--------------------------------------------------------------------------
# * State editor
#--------------------------------------------------------------------------

module Editor
  class State < Data
    STATE_CONTROLS = {
      group_box: {
        states: { label: 'State', x: 0.085, y: 0.01, width: 0.914, height: 0.98 },
        general: { label: 'General', x: 0.090, y: 0.12 },
        removal_conditions: { label: 'Removal Conditions', x: 0.27, y: 0.12, width: 0.53 },
        message1: { label: 'Message when an actor fell in the state', x: 0.27, y: 0.36, width: 0.24, height: 0.06 },
        message2: { label: 'Message when an enemy fell in the state', x: 0.27, y: 0.44, width: 0.24, height: 0.06 },
        message3: { label: 'Message when the state remains', x: 0.27, y: 0.52, width: 0.24, height: 0.06 },
        message4: { label: 'Message when the state removes', x: 0.27, y: 0.60, width: 0.24, height: 0.06 }
      },
      text_box: {
        name: { label: 'Name', length: 999_999_999, x: 0.15, y: 0.03 },
        message1: { label: 'Target', length: 999_999_999, x: 0.33, y: 0.38, width: 0.17 },
        message2: { label: 'Target', length: 999_999_999, x: 0.33, y: 0.46, width: 0.17 },
        message3: { label: 'Target', length: 999_999_999, x: 0.33, y: 0.54, width: 0.17 },
        message4: { label: 'Target', length: 999_999_999, x: 0.33, y: 0.62, width: 0.17 }
      },
      value_box: {
        priority: { label: 'Priority', min: 0, max: 100, x: 0.15, y: 0.18 },
        min_turns: { label: 'Turns:', min: 0, max: 999_999_999, x: 0.33, y: 0.22 },
        max_turns: { label: '~', min: 0, max: 999_999_999, x: 0.47, y: 0.22 },
        chance_by_damage: { label: '%', min: 0, max: 100, x: 0.47, y: 0.26 },
        steps_to_remove: { label: 'steps', min: 0, max: 999_999_999, x: 0.47, y: 0.30 }
      },
      check_box: {
        remove_at_battle_end: { label: 'Battle End', x: 0.33, y: 0.14 },
        remove_by_restriction: { label: 'Restriction', x: 0.50, y: 0.14 },
        remove_by_damage: { label: 'Damage', x: 0.33, y: 0.26 },
        remove_by_walking: { label: 'Walking', x: 0.33, y: 0.30 }
      },
      dropdown_box: {
        restriction: { label: 'Restriction', text: 'None;Attack an Enemy;Attack Anyone;Attack an Ally;Cannot Move',
                       x: 0.15, y: 0.14 },
        auto_removal_timing: { label: 'Timing', text: 'None;Action End;Turn End', x: 0.33, y: 0.18 }
      }
    }

    def initialize
      super
      @features = Features.new(@item)
      initialize_properties(STATE_CONTROLS)
    end

    def update(dt)
      super
      update_group(dt)
      update_group_item
    end

    def draw
      super
      @features.draw
      %i[states general removal_conditions message1 message2 message3 message4].each do |key|
        draw_control(:group_box, key)
      end
      %i[name message1 message2 message3 message4].each { |key| draw_control(:text_box, key, accessor: @item) }
      [:priority].each { |key| draw_control(:value_box, key, accessor: @item) }
      %i[remove_at_battle_end remove_by_restriction].each { |key| draw_control(:check_box, key, accessor: @item) }
      draw_control(:value_box, :chance_by_damage, accessor: @item) if draw_control(:check_box, :remove_by_damage,
                                                                                   accessor: @item)
      draw_control(:value_box, :steps_to_remove, accessor: @item) if draw_control(:check_box, :remove_by_walking,
                                                                                  accessor: @item)
      if STATE_CONTROLS[:dropdown_box][:auto_removal_timing][:value_index].positive?
        %i[min_turns max_turns].each { |key| draw_control(:value_box, key, accessor: @item) }
      end
      %i[restriction auto_removal_timing].each { |key| draw_control(:dropdown_box, key, accessor: @item) }
      # recursive_draw_control(STATE_CONTROLS, @item)
    end

    def update_group(dt)
      @features.update(dt)
    end

    def update_group_item
      @features.item = @item
    end
  end
end
