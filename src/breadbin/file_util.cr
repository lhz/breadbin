module Breadbin
  module FileUtil
    extend self

    def binwrite(pathname : String, address : UInt16, content : Bytes | Array(UInt8))
      File.open(pathname, "wb") do |file|
        file.write Bytes.new(2) { |i| [address % 256, address // 256][i].to_u8 }
        case content
        when Bytes
          file.write content
        when Array(UInt8)
          bytes = Bytes.new(content.size) { |i| content[i] }
          file.write bytes
        end
      end
    end
  end
end
