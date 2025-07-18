# frozen_string_literal: true

class Color
  def _dump(_depth = 0)
    @red = r
    @green = g
    @blue = b
    @alpha = a
    [@red, @green, @blue, @alpha].pack('D*')
  end

  def self._load(string)
    new(*string.unpack('D*'))
  end
end
