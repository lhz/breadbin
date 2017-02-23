module Breadbin::Image
  class Hires
    include Image

    @@pixel_width = 1

    def initialize(@width, @height, @palette)
      @pix = Pixels.new
    end

    def byte_at(x : Int32, y : Int32, color : UInt8) : UInt8
      self[x..(x + 7), y].each.with_object([0_u8, 128_u8]) { |c, o|
        o[0] += o[1] if c == color
        o[1] >>= 1
      }[0]
    end

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

    def to_bytes : Bytes
      bytes = Bytes.new(9000)
      cells = 1000.times do |i|
        cell = cell_at(i % 40, i / 40)
        bytes[8000 + i] = cell[0]
        8.times { |j| bytes[8 * i + j] = cell[1 + j] }
      end
      bytes
    end
  end
end
