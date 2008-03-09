#
#   exifparser/makernote/nikon.rb -
#
#   Copyright (C) 2002 Ryuichi Tamura (r-tam@fsinet.or.jp)
#
#   $Revision: 1.1.1.1 $
#   $Date: 2002/12/16 07:59:00 $
#
require 'exifparser/tag'
require 'exifparser/utils'

module Exif

  module Tag

    module MakerNote

      #
      # 0x0000 - Unknown
      #

      #
      # 0x0001 - Tag0x0001
      #
      class Tag0x0001 < Base

        def processData
          @formatted = []
          partition_data(@count) do |part|
            @formatted.push _formatData(part)
          end
        end

        def value
          numTags = @formatted[0] / 2
          ret = {}

          return ret if numTags < 2
          #
          # offset 1 : Macro mode
          #
          ret["Macro mode"] =
          case @formatted[1]
          when 1
            "Macro"
          when 2
            "Normal"
          else
            "Unknown"
          end

          return ret if numTags < 3
          #
          # offset 2 : if nonzero, length of self-timer in 10ths of a second.
          #
          selftimer_length = @formatted[2]

          return ret if numTags < 5
          #
          # offset 4 : Flash mode
          #
          ret["Flash mode"] =
          case @formatted[4]
          when 0
            "flash not fired"
          when 1
            "auto"
          when 2
            "on"
          when 3
            "red-eye reduction"
          when 4
            "slow synchro"
          when 5
            "auto + redeye reduction"
          when 6
            "on + redeye reduction"
          when 16
            "external flash"
          else
            "unknown"
          end

          return ret if numTags < 6
          #
          # offset 5: Contiuous drive mode
          #
          ret["Continuous drive mode"] =
          case @formatted[5]
          when 0
            if selftimer_length != 0
              "Timer = #{selftimer_length/10.0}sec."
            else
              "Single"
            end
          when 1
            "Continuous"
          end

          return ret if numTags < 8
          #
          # offset 7: Focus Mode
          #
          ret["Focus Mode"] =
          case @formatted[7]
          when 0
            "One-Shot"
          when 1
            "AI Servo"
          when 2
            "AI Focus"
          when 3
            "MF"
          when 4
            "Single"
          when 5
            "Continuous"
          when 6
            "MF"
          else
            "Unknown"
          end

          return ret if numTags < 11
          #
          # offset 10: Image size
          #
          ret["Image Size"] =
          case @formatted[10]
          when 0
            "Large"
          when 1
            "Medium"
          when
            "Small"
          else
            "Unknown"
          end

          return ret if numTags < 12
          #
          # offset 11: "Easy shooting" mode
          #
          ret["Easy shooting mode"] =
          case @formatted[11]
          when 0
            "Full auto"
          when 1
            "Manual"
          when 2
            "Landscape"
          when 3
            "Fast Shutter"
          when 4
            "Slow Shutter"
          when 5
            "Night"
          when 6
            "B&W"
          when 7
            "Sepia"
          when 8
            "Portrait"
          when 9
            "Sports"
          when 10
            "Macro / Close-Up"
          when 11
            "Pan Focus"
          else
            "Unknown"
          end

          return ret if numTags < 14
          #
          # offset 13: Contrast
          #
          ret["Contrast"] =
          case @formatted[13]
          when 0xffff
            "Low"
          when 0x0000
            "Normal"
          when 0x0001
            "High"
          else
            "Unknown"
          end

          return ret if numTags < 15
          #
          # offset 14: Saturation
          #
          ret["Saturation"] =
          case @formatted[14]
          when 0xffff
            "Low"
          when 0x0000
            "Normal"
          when 0x0001
            "High"
          else
            "Unknown"
          end

          return ret if numTags < 16
          #
          # offset 15: Contrast
          #
          ret["Sharpness"] =
          case @formatted[15]
          when 0xffff
            "Low"
          when 0x0000
            "Normal"
          when 0x0001
            "High"
          else
            "Unknown"
          end

          return ret if numTags < 17
          #
          # offset 16: ISO
          #
          ret["ISO"] =
          case @formatted[16]
          when 0
            "ISOSpeedRatings"
          when 15
            "Auto"
          when 16
            50
          when 17
            100
          when 18
            200
          when 19
            400
          else
            "Unknown"
          end

          return ret if numTags < 18
          #
          # offset 17: Metering mode
          #
          ret['Metering mode'] =
          case @formatted[17]
          when 3
            "Evaluative"
          when 4
            "Partial"
          when 5
            "Center-weighted"
          else
            "Unknown"
          end
          ret
        end

      end

      #
      # 0x0003 - Tag0x0003
      #
      class Tag0x0003 < Base
      end

      #
      # 0x0004 - Tag0x0004
      #
      class Tag0x0004 < Base

        def processData
          @formatted = []
          partition_data(@count) do |part|
            @formatted.push _formatData(part)
          end
        end

        def value
          numTags = @formatted[0] / 2
          ret = {}

          return hash if numTags < 8
          # offset 7 : white balance
          ret['White balance'] =
          case @formatted[7]
          when 0
            "Auto"
          when 1
            "Sunny"
          when 2
            "Cloudy"
          when 3
            "Tungsten"
          when 4
            "Florescent"
          when 5
            "Flash"
          when 6
            "Custom"
          else
            "Unknown"
          end

          return ret if numTags < 10
          # offset 9: Sequence number (if in a continuous burst)
          ret['Sequence number'] = @formatted[9]

          return ret if numTags < 15
          # offset 14: Auto Focus point used
          ret['Auto Focus point used'] = @formatted[14]

          return ret if numTags < 16
          ret['Flash bias'] =
          case @formatted[15]
          when 0xffc0
            "-2 EV"
          when 0xffcc
            "-1.67 EV"
          when 0xffd0
            "-1.50 EV"
          when 0xffd4
            "-1.33 EV"
          when 0xffe0
            "-1 EV"
          when 0xffec
            "-0.67 EV"
          when 0xfff0
            "-0.50 EV"
          when 0xfff4
            "-0.33 EV"
          when 0x0000
            "0 EV"
          when 0x000c
            "0.33 EV"
          when 0x0010
            "0.50 EV"
          when 0x0014
            "0.67 EV"
          when 0x0020
            "1 EV"
          when 0x002c
            "1.33 EV"
          when 0x0030
            "1.50 EV"
          when 0x0034
            "1.67 EV"
          when 0x0040
            "2 EV"
          else
            "Unknown"
          end

          return ret if numTags < 20
          ret['Subject Distance'] = @formatted[19]

          ret
        end

      end

      #
      # 0x0006 - ImageType
      #
      class ImageType < Base
      end

      #
      # 0x0007 - FirmwareVersion
      #
      class FirmwareVersion < Base
      end

      #
      # 0x0008 - ImageNumber
      #
      class ImageNumber < Base
      end

      #
      # 0x0009 - OwnerName
      #
      class OwnerName < Base
      end

      #
      # 0x000a - Unknown
      #

      #
      # 0x000c - CameraSerialNumber
      #
      class CameraSerialNumber < Base

        def to_s
          hi = @formatted / 0x10000
          low = @formatted % 0x10000
          "%04X%05d"%[hi, low]
        end

      end

      #
      # 0x000d - Unknown
      #

      #
      # 0x000f - CustomFunctions
      #
      class CustomFunctions < Base

        def processData
          @formatted = []
          partition_data(@count) do |part|
            @formatted.push _formatData(part)
          end
        end

      end

    end

    CanonIFDTable = {
      0x0000 => Unknown,
      0x0001 => MakerNote::Tag0x0001,
      0x0003 => MakerNote::Tag0x0003,
      0x0004 => MakerNote::Tag0x0004,
      0x0006 => MakerNote::ImageType,
      0x0007 => MakerNote::FirmwareVersion,
      0x0008 => MakerNote::ImageNumber,
      0x0009 => MakerNote::OwnerName,
      0x000a => Unknown,
      0x000c => MakerNote::CameraSerialNumber,
      0x000d => Unknown,
      0x000f => MakerNote::CustomFunctions
    }

  end

  class Canon

    def initialize(fin, tiff_origin, dataPos, byteOrder_module)
      @fin = fin
      @tiffHeader0 = tiff_origin
      @dataPos = dataPos
      @byteOrder_module = byteOrder_module
      self.extend @byteOrder_module
    end

    def scan_IFD
      #
      # Canon MakerNote starts from 0
      #
      @fin.pos = @dataPos + 0
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
        tagclass = Tag.find(tag.hex, Tag::CanonIFDTable)
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
