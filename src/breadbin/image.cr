require "stumpy_png"

require "./palette"

# FIXME: Move into separate file
struct StumpyCore::RGBA
  def to_rgb24 : Int32
    r, g, b = to_rgb8
    (r.to_i << 16) + (g.to_i << 8) + b.to_i
  end
end

module Breadbin
  class Image

    property width
    property height
    property palette

    getter? multi
    getter pix : Array(Array(UInt8))

    def self.read_hires(pathname)
      image = new(multi = false)
      image.read_png pathname
      image
    end

    def self.read_multi(pathname)
      image = new(multi = true)
      image.read_png pathname
      image
    end

    def initialize(multi = false)
      @multi   = multi
      @width   = 0
      @height  = 0
      @pix     = [] of Array(UInt8)
      @palette = Palette.new(Palette::Name::Pepto)
    end

    def [](x, y)
      @pix[y][x]
    end

    def read_png(path)
      png = StumpyPNG::PNG.new
      StumpyPNG::Datastream.read(path).chunks.each do |chunk|
        png.parse_chunk(chunk)
      end

      @width   = png.canvas.width / xstep
      @height  = png.canvas.height
      @palette = Palette.matching(png.palette.map &.to_rgb24)

      @pix = 0.upto(@height - 1).to_a.map do |y|
        0.upto(@width - 1).to_a.map do |x|
          @palette.index_rgb png.canvas[x * xstep, y].to_rgb24
        end
      end
    end

    private def xstep
      multi? ? 2 : 1
    end
  end
end
