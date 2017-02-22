require "./spec_helper"
require "../src/breadbin/image"

describe Breadbin::Image::Multicolor do

  context "with an existing png image" do
    image = Breadbin::Image::Multicolor.from_png("spec/fixtures/bitmap-multi.png")

    describe "#read" do
      it "picks the expected palette variant" do
        image.palette.variant.should eq(Breadbin::Palette::Variant::Pepto)
      end
      it "sets the width to half that of the png" do
        image.width.should eq(160)
      end
      it "sets the height to that of the png" do
        image.height.should eq(200)
      end
      it "extracts multicolor pixels" do
        image[49,  74].should eq(4)
        image[84, 142].should eq(6)
      end
    end

    describe "#cell_at" do
      bytes = image.cell_at(12, 8, 0_u8)
      it "returns an array of color and bitmap data for the given 4x8 cell" do
        bytes.should eq([107, 12, 228, 212, 229, 232, 229, 248, 229, 248])
      end
    end

    describe "#to_koala" do
      koala = image.to_koala(0_u8)
      it "returns an array of bytes representing the image in KoalaPainter format" do
        koala.size.should eq(10001)
        cn = 8*40 + 12
        koala[8000 + cn].should eq(107)
        koala[9000 + cn].should eq(12)
        koala[8*cn, 8].should eq(Bytes[228, 212, 229, 232, 229, 248, 229, 248])
      end
    end
  end
end
