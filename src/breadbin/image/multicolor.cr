module Breadbin::Image
  class Multicolor
    include Image

    @@pixel_width = 2

    def initialize(@width, @height, @palette)
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
      cpix = pix_rect(col * 4, row * 8, 4, 8)
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

    def to_koala(bgcolor : UInt8 = 0) : Bytes
      koala = Bytes.new(10001)
      cells = 1000.times do |i|
        cell = cell_at(i % 40, i / 40, bgcolor)
        koala[8000 + i] = cell[0]
        koala[9000 + i] = cell[1]
        8.times { |j| koala[8 * i + j] = cell[2 + j] }
      end
      koala[10000] = bgcolor
      koala
    end

    private def pix_rect(x0 : Int32, y0 : Int32, w : Int32, h : Int32) : Array(UInt8)
      h.times.map { |y|
        w.times.map { |x|
          @pix[y0 + y][x0 + x]
        }.to_a
      }.to_a.flatten
    end

    private def lookup_color(c : UInt8, colors : Array(UInt8 | Array(UInt8))) : UInt8
      colors.each.with_index do |ci, i|
        return (i + 1).to_uint8 if ci == c || (ci.is_a?(Array) && ci.includes?(c))
      end
      return 0_u8
    end

    private def most_used_colors(colors : Array(UInt8), bgcolor : UInt8) : Array(UInt8)
      freq = Array({UInt8, Int32}).new(16)
      16.times { |i|
        freq << {i.to_u8, 0}
      }
      colors.reject {|c|
        c == bgcolor
      }.each { |c|
        freq[c] = {freq[c][0], freq[c][1] + 1}
      }
      freq.sort_by {|k, v| -v}.map(&.first)
    end

    private def nearest_color_in_set(color : UInt8, set : Array(UInt8))
      lum = [0, 255, 80, 159, 96, 128, 64, 191, 96, 64, 128, 80, 120, 191, 120, 159]
      set.min_by {|c| (lum[c] - lum[color]).abs }
    end

    private def dump(name : String, bytes : Array(UInt8))
      print "#{name}: "
      puts bytes.map { |b| "%02X" % b }.join(":")
    end
  end
end
