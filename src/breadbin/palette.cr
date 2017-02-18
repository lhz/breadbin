module Breadbin
  class Palette

    class UnknownColor < Exception; end
    class NoMatch < Exception; end

    property name

    enum Name
      Colodore
      Pepto
      Levy
      Vice
      ViceOld
    end

    RGB_VALUES = {
      Name::Colodore => [
        0x000000, 0xffffff, 0x813338, 0x75cec8,
        0x8e3c97, 0x56ac4d, 0x2e2c9b, 0xedf171,
        0x8e5029, 0x553800, 0xc46c71, 0x4a4a4a,
        0x7b7b7b, 0xa9ff9f, 0x706deb, 0xb2b2b2
      ],
      Name::Pepto => [
        0x000000, 0xffffff, 0x68372b, 0x70a4b2,
        0x6f3d86, 0x588d43, 0x352879, 0xb8c76f,
        0x6f4f25, 0x433900, 0x9a6759, 0x444444,
        0x6c6c6c, 0x9ad284, 0x6c5eb5, 0x959595
      ],
      Name::Levy => [
        0x040204, 0xfcfefc, 0xcc3634, 0x84f2dc,
        0xcc5ac4, 0x5cce34, 0x4436cc, 0xf4ee5c,
        0xd47e34, 0x945e34, 0xfc9a94, 0x5c5a5c,
        0x8c8e8c, 0x9cfe9c, 0x74a2ec, 0xc4c2c4
      ],
      Name::Vice => [
        0x000000, 0xfdfefc, 0xbe1a24, 0x30e6c6,
        0xb41ae2, 0x1fd21e, 0x211bae, 0xdff60a,
        0xb84104, 0x6a3304, 0xfe4a57, 0x424540,
        0x70746f, 0x59fe59, 0x5f53fe, 0xa4a7a2
      ],
      Name::ViceOld => [
        0x000000, 0xd5d5d5, 0x72352c, 0x659fa6,
        0x733a91, 0x568d35, 0x2e237d, 0xaeb75e,
        0x774f1e, 0x4b3c00, 0x9c635a, 0x474747,
        0x6b6b6b, 0x8fc271, 0x675db6, 0x8f8f8f
      ]
    }

    def self.matching(colors : Array(Int32))
      match = Name.values.find do |name|
        colors.all? { |rgb24| RGB_VALUES[name].includes? rgb24 }
      end
      raise NoMatch.new unless match
      new(match)
    end

    def initialize(@name : Name)
    end
    
    def index_rgb(rgb24) : UInt8
      index = Palette::RGB_VALUES[@name].index(rgb24)
      raise Palette::UnknownColor.new("RGB value #{rgb24.to_s(16)}") unless index
      index.to_u8
    end
    
    class Colodore < Palette
      def initialize; super Name::Colodore; end
    end

    class Pepto < Palette
      def initialize; super Name::Pepto; end
    end

    class Levy < Palette
      def initialize; super Name::Levy; end
    end

    class Vice < Palette
      def initialize; super Name::Vice; end
    end

    class ViceOld < Palette
      def initialize; super Name::ViceOld; end
    end
  end
end
