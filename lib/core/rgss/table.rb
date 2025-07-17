class Table
  attr_accessor :xsize, :ysize, :zsize, :data

  def initialize(x, y = 0, z = 0)
    unless x.is_a?(Integer) && x > 0 && y.is_a?(Integer) && z.is_a?(Integer)
      raise ArgumentError, "x must be positive, y and z non-negative integers"
    end

    @dim = 1 + (y > 0 ? 1 : 0) + (z > 0 ? 1 : 0)
    @xsize, @ysize, @zsize = x, [y, 1].max, [z, 1].max
    @data = Array.new(@xsize * @ysize * @zsize)
    update_multipliers
  end

  def [](x, y = 0, z = 0)
    idx = x + y * @xsize + z * @z_multiplier
    @data[idx]
  end

  def []=(x, y = 0, z = 0, value)
    idx = x + y * @xsize + z * @z_multiplier
    @data[idx] = value
  end

  def resize(nx, ny = 0, nz = 0)
    ny, nz = [ny, 1].max, [nz, 1].max
    return if nx == @xsize && ny == @ysize && nz == @zsize

    new_data = Array.new(nx * ny * nz)
    min_x, min_y, min_z = [@xsize, nx].min, [@ysize, ny].min, [@zsize, nz].min

    (0...min_x).each do |x|
      xy_index = x * nx
      (0...min_y).each do |y|
        xz_index = y * nx
        (0...min_z).each do |z|
          new_data[xy_index + xz_index + z] = @data[x + y * @xsize + z * @xsize * @ysize]
        end
      end
    end

    @xsize, @ysize, @zsize = nx, ny, nz
    @data = new_data
    update_multipliers
  end

  def values_at(*keys)
    keys.map do |key|
      case key
      when :xsize then @xsize
      when :ysize then @ysize
      when :zsize then @zsize
      else
        raise KeyError, "Invalid key: #{key.inspect}"
      end
    end
  end

  def _dump(_depth = 0)
    metadata = [@dim, @xsize, @ysize, @zsize, @data.size].pack('L*')
    metadata + @data.pack("S*")
  end

  def self._load(s)
    size, nx, ny, nz, items = s.unpack('L5')
    return unless items.positive? && nx.positive?

    table = new(nx, ny, nz)
    table.data = s[20..-1].unpack("S*")
    table
  end

  private

  def update_multipliers
    @z_multiplier = @xsize * @ysize
  end
end
