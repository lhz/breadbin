require "../breadbin/image"

source = ARGV[0]

image = Breadbin::Image::Multicolor.from_png(source, {0, 0, 160, 200})
image.colfix = "nearest"

fixes = 16.times.map { |c|
  image.fixcount = 0
  image.to_bytes(c.to_u8)
  [c, image.fixcount]
}

bg, fc = fixes.min_by { |(c, f)| f }
puts "Background #{bg} results in #{fc} color bug fixes."
