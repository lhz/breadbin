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
end
