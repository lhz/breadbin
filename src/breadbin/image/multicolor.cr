# A low resolution image using any three colors plus the background color
# within each 4x8 pixel cell.
#
# Each pixel in a `Multicolor` image has double horizontal width. When
# converted from a PNG image with `.from_png` only even horizontal pixels
# are considered.
class Breadbin::Image::Multicolor
  include Image

  alias ColorList = Tuple(UInt8, UInt8, UInt8)

  @@pixel_width = 2

  # Creates an image with the given *width*, *height* and *palette*.
  def initialize(@width, @height, @palette = Palette.new(Palette::Variant::Colodore))
    @pix = Pixels.new
  end

  # Get the byte representation of the 4x1 pixel area at *x* and *y*,
  # with *clist* holding the triplet of colors that should be mapped
  # to the "01", "10" and "11" bit pairs respectively
  def byte_at(x : Int32, y : Int32, clist : ColorList) : UInt8
    colors = [1, 0, 2].map {|i| clist[i] }
    self[x..(x + 3), y].each.with_object([0_u8, 64_u8]) { |c, o|
      o[0] += o[1] * lookup_color(c, colors)
      o[1] >>= 2
    }[0]
  end

  # Get a 10 bytes representation of the 4x8 pixel cell at the given *col* and *row*,
  # where the first byte holds the screen color nybbles, the second byte holds the
  # color map nybble and the remaining 8 bytes holds the bitmap data
  def cell_at(col : Int32, row : Int32, bgcolor : UInt8 = 0, sort_first : Bool = false) : Array(UInt8)
    cpix = pix_rect(Rectangle.new(col * 4, row * 8, 4, 8))
    #dump "cpix", cpix
    if sort_first
      colors = (most_used_colors(cpix, bgcolor).sort + [bgcolor] * 3).first(3)
    else
      colors = (most_used_colors(cpix, bgcolor) + [bgcolor] * 3).first(3).sort
    end
    #dump "colors", colors
    masks = {64_u8, 16_u8, 4_u8, 1_u8}
    bytes = 8.times.map do |y|
      4.times.map do |x|
        c = cpix[y * 4 + x]
        if c != bgcolor && !colors.includes?(c)
          c = nearest_color_in_set(c, colors + [bgcolor])
        end
        if c != bgcolor
          (masks[x] * ((colors.index(c) || -1) + 1)).to_u8
        else
          0_u8
        end
      end.to_a.sum
    end.to_a
    [colors[0] * 16 + colors[1], colors[2], bytes].flatten
  end

  # Get a 63 bytes sprite representation of the 12x21 pixel region at the given
  # *x* and *y* position, with *clist* holding the triplet of colors that should
  # be mapped to the "01", "10" and "11" bit pairs respectively
  def sprite_at(x : Int32, y : Int32, clist : ColorList) : Bytes
    21.times.map { |row|
      3.times.map { |col|
        byte_at x + 4 * col, y + row, clist
      }
    }.to_a.flatten
  end

  # Get a bytes representation of an image whose dimensions are 160x200 pixels.
  # If optional parameter *pad* if set to true, pads bitmap and screen data so
  # the following sections are page aligned
  def to_bytes(bgcolor : UInt8 = 0_u8, pad : Bool = false) : Bytes
    raise InvalidDimensions.new unless width == 160 && height == 200
    bytes = Bytes.new(pad ? 10217 : 10001, 0_u8)
    scr = pad ?  8192 :  8000
    col = pad ?  9216 :  9000
    bkg = pad ? 10216 : 10000
    cells = 1000.times do |i|
      cell = cell_at(i % 40, i / 40, bgcolor)
      8.times { |j| bytes[8 * i + j] = cell[2 + j] }
      bytes[scr + i] = cell[0]
      bytes[col + i] = cell[1]
    end
    bytes[bkg] = bgcolor
    bytes
  end

  # Lookup a color within an array of colors and return its 1-based index within
  # the array, or 0 if its not included
  private def lookup_color(c : UInt8, colors : Array(UInt8 | Array(UInt8))) : UInt8
    colors.each.with_index do |ci, i|
      return (i + 1).to_uint8 if ci == c || (ci.is_a?(Array) && ci.includes?(c))
    end
    return 0_u8
  end

  private def dump(name : String, bytes : Array(UInt8))
    print "#{name}: "
    puts bytes.map { |b| "%02X" % b }.join(":")
  end
end
