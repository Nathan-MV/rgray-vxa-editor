# frozen_string_literal: true

# Input-related functions: touch
module Touch
  # @!method x
  #   Get touch position X for touch point 0 (relative to screen size)
  #   @return [Integer]

  # @!method y
  #   Get touch position Y for touch point 0 (relative to screen size)
  #   @return [Integer]

  # @!method position
  #   Get touch position XY for a touch point index (relative to screen size)
  #   @param index [Integer]
  #   @return [Vec2]

  # @!method point_id
  #   Get touch point identifier for given index
  #   @param index [Integer]
  #   @return [Integer]

  # @!method point_count
  #   Get number of touch points
  #   @return [Integer]
end
