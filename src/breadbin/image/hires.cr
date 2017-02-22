module Breadbin::Image
  class Hires
    include Image

    @@pixel_width = 1

    def initialize(@width, @height, @palette)
      @pix = Pixels.new
    end
  end
end
