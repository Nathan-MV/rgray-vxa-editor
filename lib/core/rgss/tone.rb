class Tone
  attr_accessor :red
  attr_accessor :green
  attr_accessor :blue
  attr_accessor :gray

  def initialize(red = 0, green = 0, blue = 0, gray = 0)
    self.red, self.green, self.blue, self.gray = red, green, blue, gray
  end

  def set(red, green=0, blue=0, gray=0)
    if red.is_a? Tone
      tone   = red
      @red   = tone.red
      @green = tone.green
      @blue  = tone.blue
      @gray  = tone.gray
    else
      @red   = red
      @green = green
      @blue  = blue
      @gray  = gray
    end
  end

  def red=(value) # :nodoc:
    @red = [[-255, value].max, 255].min
  end

  def green=(value) # :nodoc:
    @green = [[-255, value].max, 255].min
  end

  def blue=(value) # :nodoc:
    @blue = [[-255, value].max, 255].min
  end

  def gray=(value) # :nodoc:
    @gray = [[0, value].max, 255].min
  end

  def to_s # :nodoc:
    "(#{red}, #{green}, #{blue}, #{gray})"
  end

  def blend(tone) # :nodoc:
    self.clone.blend!(tone)
  end

  def blend!(tone) # :nodoc:
    self.red   += tone.red
    self.green += tone.green
    self.blue  += tone.blue
    self.gray  += tone.gray
    self
  end

  def _dump(marshal_depth = -1) # :nodoc:
    [@red, @green, @blue, @gray].pack('E4')
  end

  def self._load(data) # :nodoc:
    new(*data.unpack('E4'))
  end
end