require "../breadbin/image"

if ARGV.size == 0 || ARGV.any? { |f| !f.ends_with?(".png") }
  abort "Usage: bgdetect <png-file>+"
end

# Color indices ordered by probability of being used as background
COLORS = [0, 15, 12, 11, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14]

def detect_bgcolor(png_file)
  image = Breadbin::Image::Multicolor.from_png(png_file, {0, 0, 160, 200})
  image.colfix = "nearest"
  bg, fc = -1, 9999
  COLORS.each do |c|
    image.to_bytes(c.to_u8)
    if image.fixcount < fc
      bg, fc = c, image.fixcount
      break if image.fixcount == 0
    end
  end
  if fc == 0
    puts "[%2d] %s" % [bg, png_file]
  else
    STDERR.puts "[%2d] %s (WARNING: %d cells with issues)" % [bg, png_file, fc]
  end
rescue ex : Breadbin::Image::InvalidType
  STDERR.puts "ERROR: #{ex.message}"
end

ARGV.each do |file|
  detect_bgcolor file
end
