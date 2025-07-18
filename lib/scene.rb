# frozen_string_literal: true

# Scene
#  This module manages scene transitions. For example, it can handle
# hierarchical structures such as calling the item screen from the main menu
# or returning from the item screen to the main menu.

module Scene
  # Module Instance Variables
  @scene = nil # current scene object
  @stack = [] # stack for hierarchical transitions

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

    def editor_scene?(class_name)
      class_name.start_with?('Editor::')
    end
  end
end
