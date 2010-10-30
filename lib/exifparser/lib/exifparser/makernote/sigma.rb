#
#   exifparser/makernote/sigma.rb
#
#   $Revision: 1.1 $
#   $Date: 2010/10/23 16:41:28 $
#
require 'exifparser/tag'
require 'exifparser/utils'

module Exif

  module Tag

    module MakerNote
      #
      # 0x0002 - SigmaSerialNo
      #
#     class SigmaSerialNo < Base
#     end

      #
      # 0x0003 - DriveMode
      #
      class DriveMode < Base
      end

      #
      # 0x0004 - ImageSize
      #
      class ImageSize < Base
      end

      #
      # 0x0005 - AF_Mode
      #
      class AF_Mode < Base
      end

      #
      # 0x0006 - AF_Setting
      #
      class AF_Setting < Base
      end

      #
      # 0x0007 - White_Balance
      #
      class White_Balance < Base
      end

      #
      # 0x0008 - ExposureMode
      #
      class ExposureMode < Base
      end

      #
      # 0x0009 - MeteringMode
      #
      class MeteringMode < Base
      end

      #
      # 0x000a - FocalLength
      #
      class  FocalLength  < Base
      end

      #
      # 0x000b - ColorSpace
      #
      class ColorSpace  < Base
      end

      #
      # 0x000c - ExposureBias
      #
      class ExposureBias < Base
      end

      #
      # 0x000d - Contrast
      #
      class Contrast < Base
      end

      #
      # 0x000e - Shadow
      #
      class Shadow < Base
      end

      #
      # 0x000f -  HighLight
      #
      class HighLight < Base
      end

      #
      # 0x0010 - Saturation
      #
      class Saturation
      end

      #
      # 0x0011 - SharpnessBias
      #
      class SharpnessBias < Base
      end

      #
      # 0x0012 - X3FillLight
      #
      class X3FillLight < Base
      end

      #
      # 0x0014 - ColorControl
      #
      class ColorControl < Base
      end

      #
      # 0x0015 - SettingMode
      #
      class SettingMode < Base
      end

      #
      # 0x0017 - Firmware
      #
      class Firmware < Base
      end

      #
      # 0x0018 - SigmaSoftware
      #
      class SigmaSoftware < Base
      end

      #
      # 0x0019 - AutoBracket
      #
      class AutoBracket < Base
      end

    end

    SigmaIFDTable = {
#     0x0002 => MakerNote::SigmaSerialNo,
      0x0003 => MakerNote::DriveMode,
      0x0004 => MakerNote::ImageSize,
      0x0005 => MakerNote::AF_Mode,
      0x0006 => MakerNote::AF_Setting,
      0x0007 => MakerNote::White_Balance,
      0x0008 => MakerNote::ExposureMode,
      0x0009 => MakerNote::MeteringMode,
      0x000a => MakerNote::FocalLength,
      0x000b => MakerNote::ColorSpace,
      0x000c => MakerNote::ExposureBias,
      0x000d => MakerNote::Contrast,
      0x000e => MakerNote::Shadow,
      0x000f => MakerNote::HighLight,
      0x0010 => MakerNote::Saturation,
      0x0011 => MakerNote::SharpnessBias,
      0x0012 => MakerNote::X3FillLight,
      0x0014 => MakerNote::ColorControl,
      0x0015 => MakerNote::SettingMode,
      0x0017 => MakerNote::Firmware,
      0x0018 => MakerNote::SigmaSoftware,
      0x0019 => MakerNote::AutoBracket
    }

  end

  class Sigma

    def initialize(fin, tiff_origin, dataPos, byteOrder_module)
      @fin = fin
      @tiffHeader0 = tiff_origin
      @dataPos = dataPos
      @byteOrder_module = byteOrder_module
      self.extend @byteOrder_module
    end

    def scan_IFD
      #
      # Sigma MakerNote starts from 10 byte from the origin
      #
      @fin.pos = @dataPos + 10

      #
      # get the number of tags
      #
      numDirs = decode_ushort(fin_read_n(2))

      #
      # now scan them
      #
      1.upto(numDirs) {
        curpos_tag = @fin.pos
        tag = parseTagID(fin_read_n(2))
        tagclass = Tag.find(tag.hex, Tag::SigmaIFDTable)
        unit, formatter = Tag::Format::Unit[decode_ushort(fin_read_n(2))]
        count = decode_ulong(fin_read_n(4))
        tagdata = fin_read_n(4)

        obj = tagclass.new(tag, "MakerNote", count)
        obj.extend formatter, @byteOrder_module
        obj.pos = curpos_tag
        if unit * count > 4
          curpos = @fin.pos
          begin
            @fin.pos = @tiffHeader0 + decode_ulong(tagdata)
            obj.dataPos = @fin.pos
            obj.data = fin_read_n(unit*count)
          ensure
            @fin.pos = curpos
          end
        else
          obj.dataPos = @fin.pos - 4
          obj.data = tagdata
        end
        obj.processData
        yield obj
      }
    end

    private

    def fin_read_n(n)
      @fin.read(n)
    end

  end

end
