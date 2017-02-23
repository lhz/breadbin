class Breadbin::Image::Multicolor
  include Image

  @@pixel_width = 2

  def initialize(@width, @height, @palette = Palette.new(Palette::Variant::Colodore))
    @pix = Pixels.new
  end

  def byte_at(x : Int32, y : Int32, clist : Array(UInt8)) : UInt8
    colors = [1, 0, 2].map {|i| clist[i] }
    self[x..(x + 3), y].each.with_object([0_u8, 64_u8]) { |c, o|
      o[0] += o[1] * lookup_color(c, colors)
      o[1] >>= 2
    }[0]
  end

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

  # Get a bytes representation of an image whose dimensions are 160x200 pixels
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
