require "stumpy_png"

require "./stumpy_mods"
require "./palette"

# A module for wrapping functionality common to both `Image::Hires`
# and `Image::Multicolor`
module Breadbin::Image

  alias Color = UInt8

  # A 2-dimensional pixel matrix of color nybbles
  alias Pixels = Array(Array(Color))

  struct Rectangle
    property x, y, w, h
    def initialize(@x : Int32, @y : Int32, @w : Int32, @h : Int32)
    end
  end

  class InvalidDimensions < Exception; end
  class InvalidColors < Exception; end

  property width   : Int32
  property height  : Int32
  property palette : Palette
  property colfix  : String?

  macro included
    def self.from_png(pathname : String, rect : Tuple | Rectangle? = nil)
      png = StumpyPNG::PNG.__read(pathname)
      if rect.nil?
        rect = Rectangle.new(0, 0, png.canvas.width / @@pixel_width, png.canvas.height)
      elsif rect.is_a?(Tuple)
        rect = Rectangle.new(*rect)
      end
      new(rect.w, rect.h, Palette.matching(png.palette.map &.to_rgb24)).tap do |image|
        image.convert_png png, rect
      end
    end
  end

  def [](x : Int32, y : Int32)
    @pix[y][x]
  end

  def []=(x : Int32, y : Int32, color : (Int32 | Color))
    @pix[y][x] = color.to_u8
  end

  def cell_width : Int32
    (@width * @@pixel_width / 8).ceil
  end

  def cell_height : Int32
    (@height / 8).ceil
  end

  def convert_png(png : StumpyPNG::PNG, rect : Rectangle)
    @pix = rect.y.upto(rect.h - 1).to_a.map do |y|
      rect.x.upto(rect.w - 1).to_a.map do |x|
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

  private def pix_rect(rect : Rectangle) : Array(Color)
    rect.h.times.map { |y|
      rect.w.times.map { |x|
        @pix[rect.y + y][rect.x + x]
      }.to_a
    }.to_a.flatten
  end

  private def most_used_colors(colors : Array(Color), bgcolor : Color | Nil) : Array(Color)
    freq = Array({Color, Int32}).new(16)
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
  private def nearest_color_in_set(color : Color, set : Array(Color))
    lum = [0, 255, 80, 159, 96, 128, 64, 191, 96, 64, 128, 80, 120, 191, 120, 159]
    set.min_by {|c| (lum[c] - lum[color]).abs }
  end
end

require "./image/hires"
require "./image/multicolor"
