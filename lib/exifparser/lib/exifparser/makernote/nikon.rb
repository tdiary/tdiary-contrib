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
      # 0x0003 - Quality
      #
      class Quality < Base

        def to_s
          n = @formatted.to_i - 1
          (s, q) = n.divmod(3)

          f =
            case s
            when 0
              'VGA'
            when 1
              'SVGA'
            when 2
              'SXGA'
            when 3
              'UXGA'
            else
              'Unknown size'
          end

          f << ' ' <<
            case q
            when 0
              'Basic'
            when 1
              'Normal'
            when 2
              'Fine'
            else
              'Unknown quality'
            end
          f
        end

      end

      #
      # 0x0004 - ColorMode
      #
      class ColorMode < Base

        def to_s
          case @formatted
          when 1
            'Color'
          when 2
            'Monochrome'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x0005 - ImageAdjustment
      #
      class ImageAdjustment < Base

        def to_s
          case @formatted
          when 0
            'Normal'
          when 1
            'Bright+'
          when 2
            'Bright-'
          when 3
            'Contrast+'
          when 4
            'Contrast-'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x0006 - CCDSensitivity
      #
      class CCDSensitivity < Base

        def to_s
          case @formatted
          when 0
            'ISO80'
          when 2
            'ISO160'
          when 4
            'ISO320'
          when 5
            'ISO100'
          else
            "Unknown(#{@formatted})"
          end
      end

      end

      #
      # 0x0007 - WhiteBalance
      #
      class WhiteBalance < Base

        def to_s
          case @formatted
          when 0
            'Auto'
          when 1
            'Preset'
          when 2
            'Daylight'
          when 3
            'Incandescense'
          when 4
            'Fluorescence'
          when 5
            'Cloudy'
          when 6
            'SpeedLight'
          else
            "Unknown(#{@formatted})"
          end
      end

      end

      #
      # 0x0008 - Focus
      #
      class Focus < Base

        def to_s
          n = @formatted.numerator
          d = @formatted.denominator
          (n == 1 && d == 0) ? 'Pan Focus' : "#{n}/#{d}"
        end

      end

      #
      # 0x000a - DigitalZoom
      #
      class DigitalZoom < Base

        def to_s
          n = @formatted.numerator
          d = @formatted.denominator
          (n == 0 && d == 100) ? 'None' : "%0.1f"%[n.to_f/d.to_f]
        end

      end

      #
      # 0x000b - Converter
      #
      class Converter < Base

        def to_s
          case @formatted
          when 0
            'None'
          when 1
            'Fisheye'
          else
            'Unknown'
          end
        end

      end

    end

    NikonIFDTable = {
      0x0003 => MakerNote::Quality,
      0x0004 => MakerNote::ColorMode,
      0x0005 => MakerNote::ImageAdjustment,
      0x0006 => MakerNote::CCDSensitivity,
      0x0007 => MakerNote::WhiteBalance,
      0x0008 => MakerNote::Focus,
      0x000a => MakerNote::DigitalZoom,
      0x000b => MakerNote::Converter
    }

  end

  class Nikon

    def initialize(fin, tiff_origin, dataPos, byteOrder_module)
      @fin = fin
      @tiffHeader0 = tiff_origin
      @dataPos = dataPos
      @byteOrder_module = byteOrder_module
      self.extend @byteOrder_module
    end

    def scan_IFD
      #
      # Nikon MakerNote starts from 8 byte from the origin.
      #
      @fin.pos = @dataPos + 8
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
        tagclass = Tag.find(tag.hex, Tag::NikonIFDTable)
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
