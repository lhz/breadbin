require "stumpy_png"

require "./palette"

module Breadbin
  class Image

    property width
    property height
    property palette

    getter? multi
    getter pix : Array(Array(UInt8))

    def self.load_hires(pathname)
      image = new(multi = false)
      image.read_png pathname
      image
    end

    def self.load_multi(pathname)
      image = new(multi = true)
      image.read_png pathname
      image
    end

    def self.png(path)
      png = StumpyPNG::PNG.new
      StumpyPNG::Datastream.read(path).chunks.each do |chunk|
        png.parse_chunk(chunk)
      end
      png
    end

    def initialize(multi = false)
      @multi   = multi
      @width   = 0
      @height  = 0
      @pix     = [] of Array(UInt8)
      @palette = Palette.new(Palette::Name::Pepto)
    end

    def read_png(pathname)
      png = Image.png(pathname)
      canvas = png.canvas
      @width  = canvas.width / xstep
      @height = canvas.height
      @palette = Palette.matching(png.palette)

      @pix = 0.upto(@height - 1).to_a.map do |y|
        0.upto(@width - 1).to_a.map do |x|
          r, g, b = canvas[x * xstep, y].to_rgb8
          rgb = (r.to_i << 16) + (g.to_i << 8) + b.to_i
          @palette.index_rgb(rgb)
        end
      end
    end

    def [](x, y)
      @pix[y][x]
    end

    private def xstep
      multi? ? 2 : 1
    end
  end
end
