require "./spec_helper"
require "../src/breadbin/image"

describe Breadbin::Image do

  describe "#read_hires" do
    image = Breadbin::Image.read_hires("spec/fixtures/colodore-16x16.png")
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
      image[12,  3].should eq(3)
      image[ 5, 13].should eq(13)
    end
  end

  describe "#read_multi" do
    image = Breadbin::Image.read_multi("spec/fixtures/colodore-16x16.png")
    it "sets mode to multicolor" do
      image.multi?.should eq(true)
    end
    it "sets the width to half that of the png" do
      image.width.should eq(8)
    end
    it "sets the height to that of the png" do
      image.height.should eq(16)
    end
    it "extracts multicolor pixels" do
      image[4, 7].should eq(6)
      image[3, 9].should eq(9)
    end
  end
end
