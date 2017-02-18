require "./spec_helper"
require "../src/breadbin/palette"

describe Breadbin::Palette do

  describe ".matching" do
    context "given an array of colors from the Pepto palette" do
      palette = Breadbin::Palette.matching [0x68372b, 0x6f4f25, 0x9ad284]
      it "returns an instance of the Pepto palette" do
        palette.variant.should eq(Breadbin::Palette::Variant::Pepto)
      end
    end
    context "given an array of colors from the Levy palette" do
      palette = Breadbin::Palette.matching [0xf4ee5c, 0xd47e34, 0x74a2ec]
      it "returns an instance of the Levy palette" do
        palette.variant.should eq(Breadbin::Palette::Variant::Levy)
      end
    end
    context "given an array of unknown colors" do
      it "raises an exception" do
        expect_raises(Breadbin::Palette::NoMatch) do
          Breadbin::Palette.matching [0x123456, 0x234567, 0x345678]
        end
      end
    end
  end

  describe "#[]" do
    palette = Breadbin::Palette.new(Breadbin::Palette::Variant::Colodore)
    context "given a rgb24 value" do
      it "returns the color index if the palette contains the given value" do
        palette[0x8e5029].should eq(8)
      end
      it "raises an exception if the palette does not contain the given value" do
        expect_raises(Breadbin::Palette::UnknownColor) do
          palette[0x123456]
        end
      end
    end
    context "given a StumpyCore::RGBA value" do
      it "returns the color index if the palette contains the given value" do
        palette[StumpyCore::RGBA.new(0xc4c4_u16, 0x6c6c_u16, 0x7171_u16, 0xffff_u16)].should eq(10)
      end
      it "raises an exception if the palette does not contain the given value" do
        expect_raises(Breadbin::Palette::UnknownColor) do
          palette[StumpyCore::RGBA.new(0x1234_u16, 0x5678_u16, 0xabcd_u16, 0xffff_u16)]
        end
      end
    end
  end
end
