require "./spec_helper"
require "../src/breadbin/image"

describe Breadbin::Image do

  context "with an existing hires png image" do
    image = Breadbin::Image.read_hires("spec/fixtures/colodore-16x16.png")

    describe "#read_hires" do
      it "sets mode to hires" do
        image.multi?.should eq(false)
      end
      it "sets the width to that of the png" do
        image.width.should eq(16)
      end
      it "sets the height to that of the png" do
        image.height.should eq(16)
      end
      it "extracts hires pixels" do
        image[ 5, 13].should eq(13)
      end
    end

    describe "#cell_width" do
      it "returns the width of the image in cells" do
        image.cell_width.should eq(2)
      end
    end

    describe "#cell_height" do
      it "returns the height of the image in cells" do
        image.cell_height.should eq(2)
      end
    end

    describe "#[]" do
      it "returns the color index of the pixel at the given position" do
        image[12, 3].should eq(3)
      end
    end

    describe "#[]=" do
      image[12, 13] = 9
      it "sets the color index of the pixel at the given position" do
        image[12, 13].should eq(9)
      end
    end
  end

  context "with an existing multicolor png image" do
    image = Breadbin::Image.read_multi("spec/fixtures/bitmap-multi.png")

    describe "#read_multi" do
      it "picks the expected palette variant" do
        image.palette.variant.should eq(Breadbin::Palette::Variant::Pepto)
      end
      it "sets mode to multicolor" do
        image.multi?.should eq(true)
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

    describe "#cell_multi" do
      bytes = image.cell_multi(12, 8, 0_u8)
      it "returns an array of color and bitmap data for the given 4x8 cell" do
        bytes.should eq([107, 12, 228, 212, 229, 232, 229, 248, 229, 248])
      end
    end

    describe "#to_koala" do
      koala = image.to_koala(0_u8)
      # addr  = Bytes[0x00, 0x40]
      # File.open("/tmp/test.kla", "wb") { |f|
      #   f.write addr
      #   f.write koala
      # }
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
