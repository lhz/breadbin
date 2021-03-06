require "stumpy_core"

require "./palette_config"

module Breadbin
  class Palette

    class UnknownColor < Exception; end
    class NoMatch < Exception; end

    property variant

    def self.matching(colors : Array(Int32)) : Palette
      unique = colors.uniq.reject { |c| c == 0xffffff || c == 0x000000 }
      match = PaletteConfig.variants.find do |variant|
        # puts "Matching with #{variant}"
        matched, unmatched = unique.partition do |rgb24|
          PaletteConfig[variant].includes? rgb24
        end
        if ENV["DEBUG"]?
          matched_str = matched.map { |c| "0x%06x" % c }.join(" ")
          unmatched_str = unmatched.map { |c| "0x%06x" % c }.join(" ")
          puts "#{variant}"
          puts "    Matched: #{matched_str}"
          puts "  Unmatched: #{unmatched_str}"
        end
        unmatched.empty?
      end
      unless match
        raise NoMatch.new(unique.map { |c| "0x%06x" % c }.join(" "))
      end
      new(match)
    end

    def initialize(@variant : String)
      @index_rgb  = Hash(Int32, UInt8).new
      @index_rgba = Hash(StumpyCore::RGBA, UInt8).new
      PaletteConfig[@variant].each.with_index do |rgb24, i|
        @index_rgb[rgb24] = i.to_u8
        rgba = rgb24_to_rgba(rgb24)
        @index_rgba[rgba] = i.to_u8
      end
    end

    def [](color : StumpyCore::RGBA) : UInt8
      @index_rgba[color]? || raise Palette::UnknownColor.new("Unknown RGBA value #{color}")
    end

    def [](rgb24) : UInt8
      @index_rgb[rgb24]? || raise Palette::UnknownColor.new("Unknown RGB value #{rgb24.to_s(16)}")
    end

    def index_to_rgba(index : UInt8)
      rgb24_to_rgba PaletteConfig[@variant][index.to_i]
    end

    private def rgb24_to_rgba(rgb24 : Int32)
      r = ((rgb24 & 0xff0000) >> 16).to_u16
      g = ((rgb24 & 0x00ff00) >>  8).to_u16
      b = ((rgb24 & 0x0000ff)).to_u16
      rgba = StumpyCore::RGBA.new(r * 257, g * 257, b * 257, UInt16::MAX)
    end
  end
end
