struct StumpyCore::RGBA
  # Convert to 24-bit integer containing 8 bits per RGB channel
  def to_rgb24 : Int32
    r, g, b = to_rgb8
    (r.to_i << 16) + (g.to_i << 8) + b.to_i
  end
end


module StumpyPNG
  class PNG
    def self.__read(pathname : String)
      png = new
      StumpyPNG::Datastream.read(pathname).chunks.each do |chunk|
        png.parse_chunk(chunk)
      end
      png
    end
  end
end
