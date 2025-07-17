# frozen_string_literal: true

# Input-related functions: gamepads
module Gamepad
  # Mapping of symbolic key names to their corresponding key codes for gamepad inputs.
  # @note The key codes for gamepad inputs (e.g., `BUTTON_MIDDLE_RIGHT`) are constants defined by Raylib.
  # @example Replace the mapping for the start button
  #   Gamepad::MAPPING[:start] = Gamepad::BUTTON_MIDDLE_RIGHT
  MAPPING = {
    # Start and select buttons
    start: BUTTON_MIDDLE_RIGHT,
    select: BUTTON_MIDDLE_LEFT,
    home: BUTTON_MIDDLE,

    # Action buttons
    confirm: BUTTON_RIGHT_FACE_DOWN,
    cancel: BUTTON_RIGHT_FACE_RIGHT,
    menu: BUTTON_RIGHT_FACE_UP,
    special: BUTTON_RIGHT_FACE_LEFT,

    # Triggers and bumpers
    left_trigger: BUTTON_LEFT_TRIGGER_1,
    right_trigger: BUTTON_RIGHT_TRIGGER_1,
    left_bumper: BUTTON_LEFT_TRIGGER_2,
    right_bumper: BUTTON_RIGHT_TRIGGER_2,

    # Joystick buttons
    left_stick: BUTTON_LEFT_THUMB,
    right_stick: BUTTON_RIGHT_THUMB,

    # Directional buttons
    up: BUTTON_LEFT_FACE_UP,
    down: BUTTON_LEFT_FACE_DOWN,
    left: BUTTON_LEFT_FACE_LEFT,
    right: BUTTON_LEFT_FACE_RIGHT
  }

  AXIS_MAPPING = {
    left: [AXIS_LEFT_X, AXIS_LEFT_Y],
    right: [AXIS_RIGHT_X, AXIS_RIGHT_Y],
    triggers: [AXIS_LEFT_TRIGGER, AXIS_RIGHT_TRIGGER]
  }

  # @!parse BUTTON_UNKNOWN = 0
  #   Gamepad buttons
  #   return [Integer]

  # @!parse BUTTON_LEFT_FACE_UP = 1
  #   Gamepad buttons
  #   return [Integer]

  # @!parse BUTTON_LEFT_FACE_RIGHT = 2
  #   Gamepad buttons
  #   return [Integer]

  # @!parse BUTTON_LEFT_FACE_DOWN = 3
  #   Gamepad buttons
  #   return [Integer]

  # @!parse BUTTON_LEFT_FACE_LEFT = 4
  #   Gamepad buttons
  #   return [Integer]

  # @!parse BUTTON_RIGHT_FACE_UP = 5
  #   Gamepad buttons
  #   return [Integer]

  # @!parse BUTTON_RIGHT_FACE_RIGHT = 6
  #   Gamepad buttons
  #   return [Integer]

  # @!parse BUTTON_RIGHT_FACE_DOWN = 7
  #   Gamepad buttons
  #   return [Integer]

  # @!parse BUTTON_RIGHT_FACE_LEFT = 8
  #   Gamepad buttons
  #   return [Integer]

  # @!parse BUTTON_LEFT_TRIGGER_1 = 9
  #   Gamepad buttons
  #   return [Integer]

  # @!parse BUTTON_LEFT_TRIGGER_2 = 10
  #   Gamepad buttons
  #   return [Integer]

  # @!parse BUTTON_RIGHT_TRIGGER_1 = 11
  #   Gamepad buttons
  #   return [Integer]

  # @!parse BUTTON_RIGHT_TRIGGER_2 = 12
  #   Gamepad buttons
  #   return [Integer]

  # @!parse BUTTON_MIDDLE_LEFT = 13
  #   Gamepad buttons
  #   return [Integer]

  # @!parse BUTTON_MIDDLE = 14
  #   Gamepad buttons
  #   return [Integer]

  # @!parse BUTTON_MIDDLE_RIGHT = 15
  #   Gamepad buttons
  #   return [Integer]

  # @!parse BUTTON_LEFT_THUMB = 16
  #   Gamepad buttons
  #   return [Integer]

  # @!parse BUTTON_RIGHT_THUMB = 17
  #   Gamepad buttons
  #   return [Integer]

  # @!parse AXIS_LEFT_X = 0
  #   Gamepad axis
  #   return [Integer]

  # @!parse AXIS_LEFT_Y = 1
  #   Gamepad axis
  #   return [Integer]

  # @!parse AXIS_RIGHT_X = 2
  #   Gamepad axis
  #   return [Integer]

  # @!parse AXIS_RIGHT_Y = 3
  #   Gamepad axis
  #   return [Integer]

  # @!parse AXIS_LEFT_TRIGGER = 4
  #   Gamepad axis
  #   return [Integer]

  # @!parse AXIS_RIGHT_TRIGGER = 5
  #   Gamepad axis
  #   return [Integer]

  # @!method available?
  #   Check if a gamepad is available
  #   @param gamepad [Integer]
  #   @return [Boolean]

  # @!method name
  #   Get gamepad internal name id
  #   @param gamepad [Integer]
  #   @return [String]

  # @!method button_pressed?
  #   Check if a gamepad button has been pressed once
  #   @param gamepad [Integer]
  #   @param button [Integer]
  #   @return [Boolean]

  # @!method button_down?
  #   Check if a gamepad button is being pressed
  #   @param gamepad [Integer]
  #   @param button [Integer]
  #   @return [Boolean]

  # @!method button_released?
  #   Check if a gamepad button has been released once
  #   @param gamepad [Integer]
  #   @param button [Integer]
  #   @return [Boolean]

  # @!method button_up?
  #   Check if a gamepad button is NOT being pressed
  #   @param gamepad [Integer]
  #   @param button [Integer]
  #   @return [Boolean]

  # @!method button_pressed
  #   Get the last gamepad button pressed
  #   @return [Integer]

  # @!method axis_count
  #   Get gamepad axis count for a gamepad
  #   @param gamepad [Integer]
  #   @return [Integer]

  # @!method axis_movement
  #   Get axis movement value for a gamepad axis
  #   @param gamepad [Integer]
  #   @param axis [Integer]
  #   @return [Float]

  # @!method mappings=
  #   Set internal gamepad mappings (SDL_GameControllerDB)
  #   @param mappings [String]
  #   @return [Integer]

  # @!method vibration=
  #   Set gamepad vibration for both motors
  #   @param gamepad [Integer]
  #   @param left_motor [Float]
  #   @param right_motor [Float]
  #   @return [void]
end
