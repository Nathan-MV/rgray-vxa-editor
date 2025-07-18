# frozen_string_literal: true

class Table
  attr_accessor :xsize
  attr_accessor :ysize
  attr_accessor :zsize
  attr_accessor :data

  def initialize(x, y = 0, z = 0)
    unless x.is_a?(Integer) && x.positive? && y.is_a?(Integer) && z.is_a?(Integer)
      raise ArgumentError, 'x must be positive, y and z non-negative integers'
    end

    @dim = 1 + (y.positive? ? 1 : 0) + (z.positive? ? 1 : 0)
    @xsize = x
    @ysize = [y, 1].max
    @zsize = [z, 1].max
    @data = Array.new(@xsize * @ysize * @zsize)
    update_multipliers
  end

  def [](x, y = 0, z = 0)
    idx = x + (y * @xsize) + (z * @z_multiplier)
    @data[idx]
  end

  def []=(x, y = 0, z = 0, value)
    idx = x + (y * @xsize) + (z * @z_multiplier)
    @data[idx] = value
  end

  def resize(nx, ny = 0, nz = 0)
    ny = [ny, 1].max
    nz = [nz, 1].max
    return if nx == @xsize && ny == @ysize && nz == @zsize

    new_data = Array.new(nx * ny * nz)
    min_x = [@xsize, nx].min
    min_y = [@ysize, ny].min
    min_z = [@zsize, nz].min

    (0...min_x).each do |x|
      xy_index = x * nx
      (0...min_y).each do |y|
        xz_index = y * nx
        (0...min_z).each do |z|
          new_data[xy_index + xz_index + z] = @data[x + (y * @xsize) + (z * @xsize * @ysize)]
        end
      end
    end

    @xsize = nx
    @ysize = ny
    @zsize = nz
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
    metadata + @data.pack('S*')
  end

  def self._load(s)
    _, nx, ny, nz, items = s.unpack('L5')
    return unless items.positive? && nx.positive?

    table = new(nx, ny, nz)
    table.data = s[20..].unpack('S*')
    table
  end

  private

  def update_multipliers
    @z_multiplier = @xsize * @ysize
  end
end
