require "file_utils"

require "./spec_helper"
require "../src/breadbin/file_util"

describe Breadbin::FileUtil do

  describe ".binwrite" do
    address = 0x1234_u16
    content = Bytes[0x78, 0xa9, 0x00, 0x8d, 0x11, 0xd0, 0x18, 0xee, 0x20, 0xd0, 0x90, 0xfb]
    filename = "/tmp/breadbin.bin"

    it "it writes to the specified filename" do
      Breadbin::FileUtil.binwrite filename, address, content
      File.exists?(filename).should eq(true)
    end

    it "target file has the expected length of content plus two" do
      Breadbin::FileUtil.binwrite filename, address, content
      length = File.size(filename)
      length.should eq(content.size + 2)
    end

    Breadbin::FileUtil.binwrite filename, address, content
    length = File.size(filename)
    buffer = Bytes.new(length)
    File.open(filename, "r") do |file|
      file.read_fully(buffer)
    end
    it "contains the address header in the first two bytes" do
      (buffer[0].to_u16 + 256 * buffer[1].to_u16).should eq(address)
    end
    it "contains the content from byte two onwards" do
      buffer[2, length - 2].should eq(content)
    end

    FileUtils.rm filename
  end
end
