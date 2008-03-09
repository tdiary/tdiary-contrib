#
#   exifparser/makernote/fujifilm.rb -
#
#   Copyright (C) 2002 Ryuichi Tamura (r-tam@fsinet.or.jp)
#
#    $Revision: 1.1.1.1 $
#    $Date: 2002/12/16 07:59:00 $
#
#    Tested against FinePix 6900Z
#
require 'exifparser/tag'
require 'exifparser/utils'

#
#== References
#http://www.ba.wakwak.com/%7Etsuruzoh/Computer/Digicams/exif-e.html
#


module Exif

  module Tag

    module MakerNote

      #
      # 0x0000 - Version
      #
      class Version < Base
      end

      #
      # 0x1000 - Quality
      #
      class Quality < Base
      end

      #
      # 0x1001 - Sharpness
      #
      class Sharpness < Base

        def to_s
          case @formatted
          when 1,2
            'Weak'
          when 3
            'Standard'
          when 4
            'Strong'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x1002 - White
      #
      class White < Base

        def to_s
          case @formatted
          when 0
            'Auto'
          when 256
            'Daylight'
          when 512
            'Cloudy'
          when 768
            'DaylightColor-fluorescence'
          when 769
            'DaywhiteColor-fluorescence'
          when 770
            'WhiteColor-fluorescence'
          when 1024
            'Incandescence'
          when 3840
            'Custom white balance'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x1003 - Color
      #
      class Color < Base

        def to_s
          case @formatted
          when 0
            'Normal(STD)'
          when 256
            'High(HARD)'
          when
            'Low(ORG)'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x1004 - Tone
      #
      class Tone < Base

        def to_s
          case @formatted
          when 0
            'Normal(STD)'
          when 256
            'High(HARD)'
          when 512
            'Low(ORG)'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x1010 - FlashMode
      #
      class FlashMode < Base

        def to_s
          case @formatted
          when 0
            'Auto'
          when 1
            'On'
          when 2
            'Off'
          when 3
            'Red-eye reduction'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x1011 - FlashStrength
      #
      class FlashStrength < Base
      end

      #
      # 0x1020 - Macro
      #
      class Macro < Base

        def to_s
          case @formatted
          when 0
            'Off'
          when 1
            'On'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x1021 - Focus mode
      #
      class FocusMode < Base

        def to_s
          case @formatted
          when 0
            'Auto focus'
          when 1
            'Manual focus'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x1030 - SlowSync
      #
      class SlowSync < Base

        def to_s
          case @formatted
          when 0
            'Off'
          when 1
            'On'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x1031 - PictureMode
      #
      class PictureMode < Base

        def to_s
          case @formatted
          when 0
            'Auto'
          when 1
            'Portrait scene'
          when 2
            'Landscape scene'
          when 4
            'Sports scene'
          when 5
            'Night scene'
          when 6
            'Program Auto Exposure'
          when 256
            'Aperture prior Auto Exposure'
          when 512
            'Shutter prior Auto Exposure'
          when 768
            'Manual exposure'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x1032 - Unknown
      #

      #
      # 0x1100 - Cont_Bracket
      #
      class Cont_Bracket < Base

        def to_s
          case @formatted
          when 0
            'Off'
          when 1
            'On'
          else
            'Unknown'
          end
        end

        def name
          'Continuous/AutoBracket'
        end

      end

      #
      # 0x1200 - Unknown
      #

      #
      # 0x1300 - Blur warning
      #
      class BlurWarning < Base

        def to_s
          case @formatted
          when 0
            'No blur warning'
          when 1
            'Blur warning'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x1301 - Focus warning
      #
      class FocusWarning < Base

        def to_s
          case @formatted
          when 0
            'Auto Focus good'
          when 1
            'Out of Focus'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x1302 - AE warning
      #
      class AutoExposureWarning < Base

        def to_s
          case @formatted
          when 0
            'Auto exposure good'
          when 1
            'Over exposure'
          else
            'Unknown'
          end
        end

      end

    end

    #
    # Tags used in Fujifilm makernote
    #
    FujifilmIFDTable = {
      0x0000 => MakerNote::Version,
      0x1000 => MakerNote::Quality,
      0x1001 => MakerNote::Sharpness,
      0x1002 => MakerNote::White,
      0x1003 => MakerNote::Color,
      0x1004 => MakerNote::Tone,
      0x1010 => MakerNote::FlashMode,
      0x1011 => MakerNote::FlashStrength,
      0x1020 => MakerNote::Macro,
      0x1021 => MakerNote::FocusMode,
      0x1030 => MakerNote::SlowSync,
      0x1031 => MakerNote::PictureMode,
      0x1032 => Unknown,
      0x1100 => MakerNote::Cont_Bracket,
      0x1200 => Unknown,
      0x1300 => MakerNote::BlurWarning,
      0x1301 => MakerNote::FocusWarning,
      0x1302 => MakerNote::AutoExposureWarning
    }

  end

  class Fujifilm

    def initialize(fin, tiff_origin, dataPos, byteOrder_module)
      @fin = fin
      @tiffHeader0 = tiff_origin
      @dataPos = dataPos
      @byteOrder_module = Utils::Decode::Intel  # force Intel
      self.extend @byteOrder_module
    end

    def scan_IFD
      #
      # Fujifilm MakerNote starts from 8 byte from the origin
      #
      @fin.pos = @dataPos + 8
      offset = decode_ushort(fin_read_n(2))
      @fin.pos = @dataPos + offset
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
        tagclass = Tag.find(tag.hex, Tag::FujifilmIFDTable)
        unit, formatter = Tag::Format::Unit[decode_ushort(fin_read_n(2))]
        count = decode_ulong(fin_read_n(4))
        tagdata = fin_read_n(4)

        obj = tagclass.new(tag, "MakerNote", count)
        obj.extend formatter, @byteOrder_module
        obj.pos = curpos_tag
        if unit * count > 4
          curpos = @fin.pos
          begin
            @fin.pos = @dataPos + decode_ulong(tagdata)
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
