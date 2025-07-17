# frozen_string_literal: true

# Gestures and Touch Handling Functions (Module: rgestures)
module Gestures
  # @!method enabled=
  #   Enable a set of gestures using flags
  #   @param flags [Integer]
  #   @return [void]

  # @!method detected?
  #  Check if a gesture have been detected
  #   @param gesture [Integer]
  #   @return [Boolean]

  # @!method detected
  #   Get latest detected gesture
  #   @return [Integer]

  # @!method hold_duration
  #   Get gesture hold time in milliseconds
  #   @return [Float]

  # @!method drag_vector
  #  Get gesture drag vector
  #   @return [Vec2]

  # @!method drag_angle
  #  Get gesture drag angle
  #   @return [Float]

  # @!method pinch_vector
  #  Get gesture pinch delta
  #   @return [Vec2]

  # @!method pinch_angle
  #  Get gesture pinch angle
  #   @return [Float]
end
