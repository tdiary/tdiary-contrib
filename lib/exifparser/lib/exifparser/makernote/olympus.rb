#
#   exif/makernote/olympus.rb -
#
#   Copyright (C) Ryuichi Tamura (r-tam@fsinet.or.jp)
#
#   $Revision: 1.1.1.1 $
#    $Date: 2002/12/16 07:59:00 $
#
#== Reference
#
#http://www.ba.wakwak.com/%7Etsuruzoh/Computer/Digicams/exif-e.html
#
require 'exifparser/tag'
require 'exifparser/utils'

module Exif

  #
  # Tags used in Olympus Makernote
  #
  module Tag

    module MakerNote

      #
      # 0x0200 - SpecialMode
      #
      class SpecialMode < Base

        def processData
          @formatted = []
          partition_data(@count) do |data|
            @formatted.push _formatData(data)
          end
        end

        def to_s
          buf = "Picture taking mode: "
          case @formatted[0]
          when 0
            buf << 'Normal,'
          when 1
            buf << 'Unknown,'
          when 2
            buf << 'Fast,'
          when 3
            buf << 'Panorama,'
          else
            buf << 'Unknown,'
          end
          buf << " Sequence number: #{@formatted[1]},"
          buf << " Panorama direction: "
          case @formatted[2]
          when 1
            buf << 'left to right'
          when 2
            buf << 'right to left'
          when 3
            buf << 'bottom to top'
          when 4
            buf << 'top to bottom'
          else
            buf << 'unknown'
          end
        end

      end

      #
      # 0x0201 - JpegQual
      #
      class JpegQual < Base

        def to_s
          case @formatted
          when 1
            "Standard Quality"
          when 2
            "High Quality"
          when 3
            "Super High Quality"
          else
            "Unknown"
          end
        end

      end

      #
      # 0x0202 - Macro
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
      # 0x0203 - Unknown
      #

      #
      # 0x0204 - DigiZoom
      #
      class DigiZoom < Base
      end

      #
      # 0x0205 - Unknown
      #

      #
      # 0x0206 - Unknown
      #

      #
      # 0x0207 - SoftwareRelease
      #
      class SoftwareRelease < Base
      end

      #
      # 0x0208 - PictInfo
      #
      class PictInfo < Base
      end

      #
      # 0x0209 - CameraID
      #
      class CameraID < Base
      end

      #
      # 0x0f00
      #
      class DataDump < Base
      end

    end

    OlympusIFDTable = {
      0x0200 => MakerNote::SpecialMode,
      0x0201 => MakerNote::JpegQual,
      0x0202 => MakerNote::Macro,
      0x0203 => Unknown,
      0x0204 => MakerNote::DigiZoom,
      0x0205 => Unknown,
      0x0206 => Unknown,
      0x0207 => MakerNote::SoftwareRelease,
      0x0208 => MakerNote::PictInfo,
      0x0209 => MakerNote::CameraID,
      0x0f00 => MakerNote::DataDump
    }

  end

  class Olympus

    def initialize(fin, tiff_origin, dataPos, byteOrder_module)
      @fin = fin
      @tiffHeader0 = tiff_origin
      @dataPos = dataPos
      @byteOrder_module = byteOrder_module
      self.extend @byteOrder_module
    end

    def scan_IFD
      #
      # Olympus MakerNote starts from 8 byte from the origin.
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
        tagclass = Tag.find(tag.hex, Tag::OlympusIFDTable)
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
