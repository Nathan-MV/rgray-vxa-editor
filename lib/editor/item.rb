# frozen_string_literal: true

module Editor
  class Item < Data
    ICON_SIZE = 24
    TILE_COUNT = 16
    ITEM_CONTROLS = {
      group_box: {
        item: { label: 'Item', x: 0.085, y: 0.01, width: 0.914, height: 0.98 },
        general: { label: 'General', x: 0.090, y: 0.12 }
      },
      text_box: {
        name: { label: 'Name', accessor: true, length: 999_999_999, x: 0.15, y: 0.03 },
        description: { label: 'Description', accessor: true, length: 999_999_999, x: 0.15, y: 0.07, width: 0.65 }
      },
      check_box: {
        consumable: { label: 'Consumable', accessor: true, x: 0.15, y: 0.22 }
      },
      value_box: {
        price: { label: 'Price', accessor: true, min: 0, max: 999_999_999, x: 0.15, y: 0.18, width: 0.06 }
      },
      dropdown_box: {
        occasion: { label: 'Occasion', text: 'Always;Battle;Menu;Never', accessor: true, x: 0.15, y: 0.30 },
        scope: { label: 'Scope',
                 text: 'None;One Enemy;All Enemies;1 Random Enemy;2 Random Enemy;3 Random Enemy;4 Random Enemy;One Ally;All Allies;One Ally (Dead);All Allies (Dead);The User', accessor: true, x: 0.15, y: 0.26 },
        itype_id: { label: 'Item Type', text: 'None;Regular;Key', accessor: true, x: 0.15, y: 0.14 }
      }
      # combo_box: {
      #  icon_index: { label: 'Icon', accessor: true, recursive: false, x: 0.25, y: 0.03 },
      # }
    }

    def initialize
      super
      @effects = Effects.new(@item)
      @damage = Damage.new(@item)
      @invocation = Invocation.new(@item)
      initialize_properties(ITEM_CONTROLS)
      @sprite = Sprite.new('./Project/Graphics/System/iconset.png')
      @sprite_pos = Vec2.new(Graphics.screen_width * 0.28, Graphics.screen_height * 0.03)
    end

    def update(dt)
      super
      update_group(dt)
      update_group_item
    end

    def draw
      super
      @effects.draw
      @damage.draw
      @invocation.draw
      recursive_draw_control(ITEM_CONTROLS, @item)
      draw_icon(@item.icon_index)
    end

    private

    def update_group(dt)
      @effects.update(dt)
      @damage.update(dt)
      @invocation.update(dt)
    end

    def update_group_item
      @effects.item = @item
      @damage.item = @item
      @invocation.item = @item
    end

    # Calculate the position of the icon in the texture based on icon_index and draw it
    def draw_icon(icon_index)
      icon_x = (icon_index % TILE_COUNT) * ICON_SIZE
      icon_y = (icon_index / TILE_COUNT) * ICON_SIZE
      source_rect = Rect.new(icon_x, icon_y, ICON_SIZE, ICON_SIZE)
      @sprite.draw_rect(source_rect, @sprite_pos)
    end
  end
end
