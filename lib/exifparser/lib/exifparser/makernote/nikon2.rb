#
#   exif/makernote/nikon2.rb
#
#   $Revision: 1.3 $
#    $Date: 2003/04/27 13:54:52 $
#
#== Reference
#
#http://www.ba.wakwak.com/%7Etsuruzoh/Computer/Digicams/exif-e.html
#
require 'exifparser/tag'
require 'exifparser/utils'

module Exif

  #
  # Tags used in Nikon Makernote
  #
  module Tag

    module MakerNote

      #
      # 0x0002 - ISOSetting
      #
      class ISOSetting < Base
      end

      #
      # 0x0003 - ColorMode
      #
      class ColorMode < Base
      end

      #
      # 0x0004 - Quality
      #
      class Quality < Base
      end

      #
      # 0x0005 - Whitebalance
      #
      class Whitebalance < Base
      end

      #
      # 0x0006 - ImageSharpening
      #
      class ImageSharpening < Base
      end

      #
      # 0x0007 - FocusMode
      #
      class FocusMode < Base
      end

      #
      # 0x0008 - FlashSetting
      #
      class FlashSetting < Base
      end

      #
      # 0x000f - ISOSelection
      #
      class ISOSelection < Base
      end

      #
      # 0x0010 - DataDump
      #
      class DataDump < Base
      end

      #
      # 0x0080 - ImageAdjustment
      #
      class ImageAdjustment < Base
      end

      #
      # 0x0082 - Adapter
      #
      class Adapter < Base
      end

      #
      # 0x0085 - ManualForcusDistance
      #
      class ManualForcusDistance < Base
      end

      #
      # 0x0086 - DigitalZoom
      #
      class DigitalZoom < Base
      end

      #
      # 0x0088 - AFFocusPosition
      #
      class AFFocusPosition < Base
      end
      
    end

    Nikon2IFDTable = {
      0x0002 => MakerNote::ISOSetting,
      0x0003 => MakerNote::ColorMode,
      0x0004 => MakerNote::Quality,
      0x0005 => MakerNote::Whitebalance,
      0x0006 => MakerNote::ImageSharpening,
      0x0007 => MakerNote::FocusMode,
      0x0008 => MakerNote::FlashSetting,
      0x000f => MakerNote::ISOSelection,
      0x0010 => MakerNote::DataDump,
      0x0080 => MakerNote::ImageAdjustment,
      0x0082 => MakerNote::Adapter,
      0x0085 => MakerNote::ManualForcusDistance,
      0x0086 => MakerNote::DigitalZoom,
      0x0088 => MakerNote::AFFocusPosition,
    }

  end

  class Nikon2

    def initialize(fin, tiff_origin, dataPos, byteOrder_module)
      @fin = fin
      @tiffHeader0 = tiff_origin
      @dataPos = dataPos
      @nikonOffset = 0

      @fin.pos = dataPos
      magic = fin_read_n(6)

      if magic == "Nikon\000"
	@nikonOffset = 18   # D100, E5700, etc..
	fin_read_n(4)
	@tiffHeader0 = @fin.pos
	bo = @fin.read(2)
	case bo
	when "MM"
	  byteOrder_module = Utils::Decode::Motorola
	when "II"
	  byteOrder_module = Utils::Decode::Intel
	else
	  raise RuntimeError, "Unknown byte order"
	end
      end
      @byteOrder_module = byteOrder_module
      self.extend @byteOrder_module
    end

    def scan_IFD
      #
      # Nikon D1 series MakerNote starts from 0 byte from the origin.
      #
      @fin.pos = @dataPos + @nikonOffset

      #
      # get the number of tags
      #
      num_dirs = decode_ushort(fin_read_n(2))
      
      #
      # now scan them
      #
      1.upto(num_dirs) {
	curpos_tag = @fin.pos
	tag = parseTagID(fin_read_n(2))
        tagclass = Tag.find(tag.hex, Tag::Nikon2IFDTable)
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
