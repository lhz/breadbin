# A high resolution image using any two colors within each 8x8 pixel cell.
class Breadbin::Image::Hires
  include Image

  @@pixel_width = 1

  # Creates an image with the given *width*, *height* and *palette*
  def initialize(@width, @height, @palette)
    @pix = Pixels.new
  end

  # Get the byte representation of the 8x1 pixel area at *x* and *y*,
  # with *color* getting a "1" bit and any other color getting a "0" bit
  def byte_at(x : Int32, y : Int32, color : UInt8) : UInt8
    self[x..(x + 7), y].each.with_object([0_u8, 128_u8]) { |c, o|
      o[0] += o[1] if c == color
      o[1] >>= 1
    }[0]
  end

  # Get a 9 bytes representation of the 8x8 pixel cell at the given *col* and *row*,
  # where the first byte holds the color nybbles and the remaining 8 bytes hold
  # the bitmap data
  def cell_at(col : Int32, row : Int32, sort_first : Bool = false) : Array(UInt8)
    cpix = pix_rect(Rectangle.new(col * 8, row * 8, 8, 8))
    if sort_first
      colors = (most_used_colors(cpix, nil).sort + [0_u8, 0_u8]).first(2)
    else
      colors = (most_used_colors(cpix, nil) + [0_u8, 0_u8]).first(2).sort
    end
    masks = {128_u8, 64_u8, 32_u8, 16_u8, 8_u8, 4_u8, 2_u8, 1_u8}
    bytes = 8.times.map do |y|
      8.times.map do |x|
        c = cpix[y * 8 + x]
        c = nearest_color_in_set(c, colors) unless colors.includes?(c)
        (masks[x] * (colors.index(c) || 0)).to_u8
      end.to_a.sum
    end.to_a
    [colors[1] * 16 + colors[0], bytes].flatten
  end

  # Get a bytes representation of an image whose dimensions are 320x200 pixels.
  # If optional parameter *pad* if set to true, pads bitmap data so the following
  # section is page aligned
  def to_bytes(pad : Bool = false) : Bytes
    raise InvalidDimensions.new unless width == 320 && height == 200
    bytes = Bytes.new(pad ? 9192 : 9000)
    scr = pad ? 8192 : 8000
    cells = 1000.times do |i|
      cell = cell_at(i % 40, i / 40)
      bytes[scr + i] = cell[0]
      8.times { |j| bytes[8 * i + j] = cell[1 + j] }
    end
    bytes
  end
end
