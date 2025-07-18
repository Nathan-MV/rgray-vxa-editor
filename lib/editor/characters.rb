# frozen_string_literal: true

#--------------------------------------------------------------------------
# * Character editor (incomplete)
#--------------------------------------------------------------------------

module Editor
  class Characters < Base
    TEMPLATE = {
      hairs: 0,
      clothes: 0
    }

    def initialize
      # super
      @group_box_rect = Rect.new(85, 5, 385, SCREEN_HEIGHT - 10)
      initialize_rects(CHARACTERS_CONTROLS)
      @spritesheet = Spritesheet.new('graphics/characters/bodies/02.png', :character)
    end

    def update(delta)
      # super
    end

    def draw
      # super
      Gui.group_box('Character Editor', @group_box_rect)
      draw_item_controls(CHARACTERS_CONTROLS)
      draw_preview
    end

    def unload
      @spritesheet.unload
    end

    def export_character(path)
      Image.from_texture(@spritesheet.texture).export(path)
    end

    def draw_preview
      @spritesheet&.draw(Vec2.new(250, 300))
    end

    CHARACTERS_CONTROLS = {
      list_view: {
        hairs: {
          text: Dir.glob('graphics/characters/hairs/*.png').map { |p| File.basename(p, '.png') }.join(';'),
          x: 100,
          y: 50,
          width: 200,
          height: 150
        },
        clothes: {
          text: Dir.glob('graphics/characters/clothes/*.png').map { |p| File.basename(p, '.png') }.join(';'),
          x: 100,
          y: 250,
          width: 200,
          height: 150
        }
      }
    }
  end
end
