require "./spec_helper"
require "../src/breadbin/image"

describe Breadbin::Image::Hires do

  context "from an existing png image" do
    image = Breadbin::Image::Hires.from_png("spec/fixtures/bitmap-hires.png")

    describe ".from_png" do
      it "picks the expected palette variant" do
        image.palette.variant.should eq(Breadbin::Palette::Variant::ViceOld)
      end
      it "sets the width to that of the png" do
        image.width.should eq(320)
      end
      it "sets the height to that of the png" do
        image.height.should eq(200)
      end
    end

    describe "#cell_width" do
      it "returns the width of the image in cells" do
        image.cell_width.should eq(40)
      end
    end

    describe "#cell_height" do
      it "returns the height of the image in cells" do
        image.cell_height.should eq(25)
      end
    end

    describe "#[]" do
      it "returns the color index of the pixel at the given position" do
        image[121, 153].should eq(4)
        image[219, 118].should eq(12)
      end
    end

    describe "#[]=" do
      image[12, 13] = 1
      it "sets the color index of the pixel at the given position" do
        image[12, 13].should eq(1)
      end
    end

    # describe "#cell_at" do
    #   bytes = image.cell_at(12, 8)
    #   it "returns an array of color and bitmap data for the given 8x8 cell" do
    #     bytes.should eq([107, 12, 228, 212, 229, 232, 229, 248, 229, 248])
    #   end
    # end
  end
end
