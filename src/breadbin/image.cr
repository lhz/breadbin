require "stumpy_png"

require "./stumpy_mods"
require "./palette"

module Breadbin::Image

  alias Pixels = Array(Array(UInt8))

  property width   : Int32
  property height  : Int32
  property palette : Palette

  macro included
    def self.from_png(pathname : String)
      png = StumpyPNG::PNG.__read(pathname)
      pal = Palette.matching(png.palette.map &.to_rgb24)
      new(png.canvas.width / @@pixel_width, png.canvas.height, pal).tap do |image|
        image.convert_png png
      end
    end
  end

  def [](x : Int32, y : Int32)
    @pix[y][x]
  end

  def []=(x : Int32, y : Int32, color : Int32)
    @pix[y][x] = color.to_u8
  end

  def cell_width : Int32
    (@width * @@pixel_width / 8).ceil
  end

  def cell_height : Int32
    (@height / 8).ceil
  end

  def convert_png(png : StumpyPNG::PNG)
    @pix = 0.upto(@height - 1).to_a.map do |y|
      0.upto(@width - 1).to_a.map do |x|
        palette[png.canvas[x * @@pixel_width, y]]
      end
    end
  end

  def write_png(pathname : String)
    canvas = StumpyPNG::Canvas.new(@width * @@pixel_width, @height)
    height.times do |y|
      width.times do |x|
        @@pixel_width.times do |i|
          canvas[x * @@pixel_width + i, y] = palette.index_to_rgba(self[x, y])
        end
      end
    end
    StumpyPNG.write canvas, pathname
  end

  private def pix_rect(x0 : Int32, y0 : Int32, w : Int32, h : Int32) : Array(UInt8)
    h.times.map { |y|
      w.times.map { |x|
        @pix[y0 + y][x0 + x]
      }.to_a
    }.to_a.flatten
  end

  private def most_used_colors(colors : Array(UInt8), bgcolor : UInt8 | Nil) : Array(UInt8)
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

  # FIXME: Move to Palette?
  private def nearest_color_in_set(color : UInt8, set : Array(UInt8))
    lum = [0, 255, 80, 159, 96, 128, 64, 191, 96, 64, 128, 80, 120, 191, 120, 159]
    set.min_by {|c| (lum[c] - lum[color]).abs }
  end
end

require "./image/hires"
require "./image/multicolor"
