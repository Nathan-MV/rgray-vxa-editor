# frozen_string_literal: true

#--------------------------------------------------------------------------
# * Damage group
#--------------------------------------------------------------------------

module Editor
  class Damage < Base
    attr_accessor :item

    DAMAGE_CONTROLS = {
      group_box: {
        damage: { label: 'Damage', x: 0.27, y: 0.12, width: 0.53 }
      },
      text_box: {
        formula: { label: 'Formula', tooltip: 'Formula for calculating base damage', length: 1000, x: 0.33, y: 0.22,
                   width: 0.46 }
      },
      check_box: {
        critical: { label: 'Critical Hits', x: 0.33, y: 0.30 }
      },
      value_box: {
        variance: { label: 'Variance %', min: 0, max: 100, x: 0.33, y: 0.26, width: 0.03 }
      },
      dropdown_box: {
        element_id: { label: 'Element', x: 0.33, y: 0.18 },
        type: { label: 'Type', text: 'None;HP Damage;MP Damage;HP Recover;MP Recover;HP Drain;MP Drain', x: 0.33,
                y: 0.14 }
      }
    }

    def initialize(item)
      super
      @item = item
      initialize_properties(DAMAGE_CONTROLS)
    end

    def draw
      super
      draw_control(:group_box, :damage)
      if @item.damage.type.positive?
        draw_control(:check_box, :critical, accessor: @item.damage)
        draw_control(:value_box, :variance, accessor: @item.damage)
        draw_control(:text_box, :formula, accessor: @item.damage)
        draw_control(:dropdown_box, :element_id, accessor: @item.damage,
                                                 special_value: "None#{$data_system.elements.compact.join(';')}")
      end
      draw_control(:dropdown_box, :type, accessor: @item.damage)
    end
  end
end

#--------------------------------------------------------------------------
# * Critical plugin
#--------------------------------------------------------------------------

# Create the new accessors
module RPG
  class UsableItem
    class Damage
      attr_accessor :critical_chance
      attr_accessor :critical_multiplier

      alias ece_alias_initialize initialize
      def initialize
        ece_alias_initialize
        @critical_chance = 0
        @critical_multiplier = 0
      end
    end
  end
end

module Editor
  # Update existing items
  class Data < Base
    alias ece_alias_initialize_items_damage_critical initialize_items
    def initialize_items
      ece_alias_initialize_items_damage_critical
      @items.each do |item|
        next unless item.respond_to?(:damage)

        safe_attribute(item.damage, :critical_chance, 0)
        safe_attribute(item.damage, :critical_multiplier, 0)
      end
    end
  end

  # Draw the controls for the new accessors
  class Damage < Base
    DAMAGE_CONTROLS[:value_box][:critical_chance] =
      { label: 'Chance %', min: 0, max: 100, x: 0.41, y: 0.30, width: 0.03 }
    DAMAGE_CONTROLS[:value_box][:critical_multiplier] =
      { label: 'Multiplier', min: 0, max: 100, x: 0.50, y: 0.30, width: 0.03 }

    alias ece_alias_draw draw
    def draw
      if @item.damage.critical
        draw_control(:value_box, :critical_chance, accessor: @item.damage)
        draw_control(:value_box, :critical_multiplier, accessor: @item.damage)
      end
      ece_alias_draw
    end
  end
end
