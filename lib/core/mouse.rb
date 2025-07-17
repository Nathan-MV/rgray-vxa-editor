# frozen_string_literal: true

# Input-related functions: mouse
module Mouse
  MAPPING = {
    confirm: Mouse::BUTTON_LEFT,
    cancel: Mouse::BUTTON_RIGHT
  }

  # @!parse BUTTON_LEFT = 0
  #   Mouse button
  #   return [Integer]

  # @!parse BUTTON_RIGHT = 1
  #   Mouse button
  #   return [Integer]

  # @!parse BUTTON_MIDDLE = 2
  #   Mouse button
  #   return [Integer]

  # @!parse BUTTON_SIDE = 3
  #   Mouse button
  #   return [Integer]

  # @!parse BUTTON_EXTRA = 4
  #   Mouse button
  #   return [Integer]

  # @!parse BUTTON_FORWARD = 5
  #   Mouse button
  #   return [Integer]

  # @!parse BUTTON_BACK = 6
  #   Mouse button
  #   return [Integer]

  # @!parse CURSOR_DEFAULT = 0
  #   Mouse cursor
  #   return [Integer]

  # @!parse CURSOR_ARROW = 1
  #   Mouse cursor
  #   return [Integer]

  # @!parse CURSOR_IBEAM = 2
  #   Mouse cursor
  #   return [Integer]

  # @!parse CURSOR_CROSSHAIR = 3
  #   Mouse cursor
  #   return [Integer]

  # @!parse CURSOR_POINTING_HAND = 4
  #   Mouse cursor
  #   return [Integer]

  # @!parse CURSOR_RESIZE_EW = 5
  #   Mouse cursor
  #   return [Integer]

  # @!parse CURSOR_RESIZE_NS = 6
  #   Mouse cursor
  #   return [Integer]

  # @!parse CURSOR_RESIZE_NWSE = 7
  #   Mouse cursor
  #   return [Integer]

  # @!parse CURSOR_RESIZE_NESW = 8
  #   Mouse cursor
  #   return [Integer]

  # @!parse CURSOR_RESIZE_ALL = 9
  #   Mouse cursor
  #   return [Integer]

  # @!parse CURSOR_NOT_ALLOWED = 10
  #   Mouse cursor
  #   return [Integer]

  # @!method button_pressed?
  #   Check if a mouse button has been pressed once
  #   @param button [Integer]
  #   @return [Boolean]

  # @!method button_down?
  #   Check if a mouse button is being pressed
  #   @param button [Integer]
  #   @return [Boolean]

  # @!method button_released?
  #   Check if a mouse button has been released once
  #   @param button [Integer]
  #   @return [Boolean]

  # @!method button_up?
  #   Check if a mouse button is NOT being pressed
  #   @param button [Integer]
  #   @return [Boolean]

  # @!method x
  #   Get mouse position X
  #   @return [Integer]

  # @!method y
  #   Get mouse position Y
  #   @return [Integer]

  # @!method position
  #   Get mouse position XY
  #   @return [Vec2]

  # @!method delta
  #   Get mouse delta between frames
  #   @return [Vec2]

  # @!method position=
  #   Set mouse position XY
  #   @param x [Integer]
  #   @param y [Integer]
  #   @return [void]

  # @!method offset=
  #   Set mouse offset
  #   @param offsetX [Integer]
  #   @param offsetY [Integer]
  #   @return [void]

  # @!method scale=
  #   Set mouse scaling
  #   @param offsetX [Float]
  #   @param offsetY [Float]
  #   @return [void]

  # @!method wheel_move
  #   Get mouse wheel movement for X or Y, whichever is larger
  #   @return [Float]

  # @!method wheel_move_v
  #   Get mouse wheel movement for both X and Y
  #   @return [Vec2]

  # @!method cursor=
  #   Set mouse cursor
  #   @param cursor [Integer]
  #   @return [void]
end
