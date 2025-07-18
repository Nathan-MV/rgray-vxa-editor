# frozen_string_literal: true

# Scene
#  This module manages scene transitions. For example, it can handle
# hierarchical structures such as calling the item screen from the main menu
# or returning from the item screen to the main menu.

module Scene
  # Module Instance Variables
  @scene = nil # current scene object
  @stack = [] # stack for hierarchical transitions
  @old_scene = []
  @scene_file = "#{GAME_PATH}.tmp/last_scene.json".freeze # file to store the last scene

  class << self
    # Get Current Scene
    attr_reader :scene

    # Determine Current Scene Class
    def scene_is?(scene_class)
      @scene.instance_of?(scene_class)
    end

    def update(delta)
      @scene&.update(delta)
    end

    def draw
      @scene&.draw
    end

    def unload
      @scene&.unload
    end

    # Direct Transition
    def goto(scene_class)
      @old_scene << scene_class
      @scene = scene_class.new
      # save_scene_state
    end

    # Call
    def call(scene_class)
      @stack.push(@scene)
      @scene = scene_class
    end

    # Return to Caller
    def return
      @scene = @stack.pop
      GC.start
    end

    # Clear Call Stack
    def clear
      @stack.clear
    end

    # Exit Game
    def exit
      @scene = nil
    end

    def save_scene_state
      File.write(@scene_file, { scene: @scene.class.name, editor_index: Editor.index }.to_json)
    end

    def load_last_scene
      return unless File.exist?(@scene_file)

      data = JSON.parse(File.read(@scene_file), symbolize_names: true)
      scene_class = Object.const_get(data[:scene])
      return unless scene_class

      if editor_scene?(data[:scene])
        Editor.index = data[:editor_index]
        Editor.select(Editor.index)
      else
        goto(scene_class)
      end
    end

    def editor_scene?(class_name)
      class_name.start_with?('Editor::')
    end
  end
end
