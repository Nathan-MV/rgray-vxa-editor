  class Color
    def _dump(depth = 0)
      @red = self.r
      @green = self.g
      @blue = self.b
      @alpha = self.a
      [@red, @green, @blue, @alpha].pack('D*')
    end

    def self._load(string)
      self.new(*string.unpack('D*'))
    end
  end
