require "./spec_helper"
require "../src/breadbin/image"

describe Breadbin::Image::Multicolor do

  context "with an existing png image" do
    image = Breadbin::Image::Multicolor.from_png("spec/fixtures/bitmap-multi.png")

    describe "#read" do
      it "picks the expected palette variant" do
        image.palette.variant.should eq("pepto")
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

    describe "#to_bytes" do
      context "without padding (default)" do
        bytes = image.to_bytes(0_u8)
        it "returns an array of 10001 bytes representing the image in KoalaPainter format" do
          bytes.size.should eq(10001)
          cn = 8*40 + 12
          bytes[8*cn, 8].should eq(Bytes[228, 212, 229, 232, 229, 248, 229, 248])
          bytes[8000 + cn].should eq(107)
          bytes[9000 + cn].should eq(12)
        end
      end
      context "with padding" do
        bytes = image.to_bytes(0_u8, true)
        it "returns an array of bytes representing the image in padded format" do
          bytes.size.should eq(10217)
          cn = 8*40 + 12
          bytes[8*cn, 8].should eq(Bytes[228, 212, 229, 232, 229, 248, 229, 248])
          bytes[8192 + cn].should eq(107)
          bytes[9216 + cn].should eq(12)
          bytes[10216].should eq(0)
        end
      end
      context "with wrong dimensions" do
        bad_image = Breadbin::Image::Multicolor.new(16, 16)
        it "raises an exception" do
          expect_raises Breadbin::Image::InvalidDimensions do
            bad_image.to_bytes
          end
        end
      end
    end
  end

  context "from an existing png image with too many colors" do
    image = Breadbin::Image::Hires.from_png("spec/fixtures/bitmap-multi-invalid.png")

    describe "#cell_at" do
      it "raises InvalidColors in cell with more than 3 unique non-background colors" do
        expect_raises(Breadbin::Image::InvalidColors, /column 1 row 2/) do
          image.cell_at(1, 2)
        end
      end
    end
  end
end
