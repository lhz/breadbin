require "./spec_helper"
require "../src/breadbin/image"

describe Breadbin::Image do

  describe "#load_hires" do
    image = Breadbin::Image.load_hires("spec/fixtures/colodore-16x16.png")
    it "sets mode to hires" do
      image.multi?.should eq(false)
    end
    it "sets the width to that of the png" do
      image.width.should eq(16)
    end
    it "sets the height to that of the png" do
      image.height.should eq(16)
    end
  end

  describe "#load_multi" do
    image = Breadbin::Image.load_multi("spec/fixtures/colodore-16x16.png")
    it "sets mode to multicolor" do
      image.multi?.should eq(true)
    end
    it "sets the width to half that of the png" do
      image.width.should eq(8)
    end
    it "sets the height to that of the png" do
      image.height.should eq(16)
    end
  end
end
