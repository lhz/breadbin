struct StumpyCore::RGBA
  # Convert to 24-bit integer containing 8 bits per RGB channel
  def to_rgb24 : Int32
    r, g, b = to_rgb8
    (r.to_i << 16) + (g.to_i << 8) + b.to_i
  end
end
