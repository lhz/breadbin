require "../breadbin/image"

if ARGV.size == 0 || ARGV.any? { |f| !f.ends_with?(".png") }
  abort "Usage: bgdetect <png-file>+"
end

def detect_bgcolor(png_file)
  puts "Detecting background for #{png_file}"
  image = Breadbin::Image::Multicolor.from_png(png_file, {0, 0, 160, 200})
  image.colfix = "nearest"

  fixes = 16.times.map { |c|
    image.to_bytes(c.to_u8)
    [c, image.fixcount]
  }

  bg, fc = fixes.min_by { |(c, f)| f }
  print "  Background #{bg}"
  print " with #{fc} issues" if fc > 0
  puts "."
rescue ex : Breadbin::Image::InvalidType
  STDERR.puts "  WARNING: #{ex.message}"
end

ARGV.each do |file|
  detect_bgcolor file
end
