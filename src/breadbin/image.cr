require "stumpy_png"

require "./stumpy_mods"
require "./palette"

module Breadbin
  class Image

    property width
    property height
    property palette

    getter? multi
    getter pix : Array(Array(UInt8))

    def self.read_hires(pathname : String)
      image = new(multi = false)
      image.read_png pathname
      image
    end

    def self.read_multi(pathname : String)
      image = new(multi = true)
      image.read_png pathname
      image
    end

    def initialize(multi : Bool = false)
      @multi   = multi
      @width   = 0
      @height  = 0
      @pix     = [] of Array(UInt8)
      @palette = Palette.new(Palette::Variant::Pepto)
    end

    def [](x : Int32, y : Int32)
      @pix[y][x]
    end

    def read_png(pathname : String)
      png = StumpyPNG::PNG.new
      StumpyPNG::Datastream.read(pathname).chunks.each do |chunk|
        png.parse_chunk(chunk)
      end

      @palette = Palette.matching(png.palette.map &.to_rgb24)

      @width   = png.canvas.width / pixel_width
      @height  = png.canvas.height

      @pix = 0.upto(@height - 1).to_a.map do |y|
        0.upto(@width - 1).to_a.map do |x|
          @palette[png.canvas[x * pixel_width, y]]
        end
      end
    end

    private def pixel_width
      multi? ? 2 : 1
    end
  end
end
