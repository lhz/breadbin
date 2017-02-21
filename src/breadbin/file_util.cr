module Breadbin
  module FileUtil
    extend self

    def binwrite(pathname : String, address : UInt16, content : Bytes)
      File.open(pathname, "wb") do |file|
        file.write Bytes.new(2) { |i| [address % 256, address / 256][i].to_u8 }
        file.write content
      end
    end
  end
end
