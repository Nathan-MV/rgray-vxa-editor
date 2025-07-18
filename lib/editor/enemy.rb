# frozen_string_literal: true

module Editor
  class Enemy < Data
    ENEMY_CONTROLS = {
      group_box: {
        enemies: { label: 'Enemies', x: 0.085, y: 0.01, width: 0.914, height: 0.98 },
        general: { label: 'Graphics', x: 0.090, y: 0.12 },
        rewards: { label: 'Rewards', x: 0.090, y: 0.36 },
        drop_items: { label: 'Drop Items', x: 0.090, y: 0.60, height: 0.38 },
        action_patterns: { label: 'Action Patterns', x: 0.27, y: 0.36, width: 0.24, height: 0.62 }
      },
      text_box: {
        name: { label: 'Name', length: 999_999_999, x: 0.15, y: 0.03 }
      },
      value_box: {
        exp: { label: 'Exp', min: 0, max: 999_999_999, x: 0.15, y: 0.38, width: 0.06 },
        gold: { label: 'Gold', min: 0, max: 999_999_999, x: 0.15, y: 0.42, width: 0.06 }
      }
    }

    def initialize
      super
      @features = Features.new(@item)
      @parameter = Parameter.new(@item)
      initialize_properties(ENEMY_CONTROLS)
      setup_sprite
      @color = Color.new(255, 255, 255)
    end

    def update(dt)
      super
      update_groups(dt)
      refresh_sprite if @item != @previous_item
    end

    def draw
      super
      @features.draw
      @parameter.draw
      draw_controls
      @sprite.draw(@sprite_pos, 0, @color)
    end

    def unload
      # @sprite.unload
    end

    private

    def setup_sprite
      @sprite = Sprite.new(sprite_path)
      @sprite.scale = 0.5
      @sprite_pos = Vec2.new(120, 100)
      @previous_item = @item
    end

    def sprite_path
      "Project/Graphics/Battlers/#{@item.battler_name}.png"
    end

    def refresh_sprite
      @sprite.load = sprite_path
      @sprite.scale = 0.5
      @previous_item = @item
    end

    def update_groups(dt)
      @features.update(dt)
      @parameter.update(dt)
      @features.item = @item
      @parameter.item = @item
    end

    def draw_controls
      ENEMY_CONTROLS[:group_box].each_key { |key| draw_control(:group_box, key) }
      ENEMY_CONTROLS[:text_box].each_key { |key| draw_control(:text_box, key, accessor: @item) }
      ENEMY_CONTROLS[:value_box].each_key { |key| draw_control(:value_box, key, accessor: @item) }
    end
  end
end
