#
#   exifparser/makernote/minolta.rb
#
#   $Revision: 1.2 $
#   $Date: 2003/05/13 15:41:28 $
#
require 'exifparser/tag'
require 'exifparser/utils'

module Exif

  module Tag

    module MakerNote
    end

    MinoltaIFDTable = {
    }

  end

  class Minolta

    def initialize(fin, tiff_origin, dataPos, byteOrder_module)
      @fin = fin
      @tiffHeader0 = tiff_origin
      @dataPos = dataPos
      @byteOrder_module = byteOrder_module
      self.extend @byteOrder_module
    end

    def scan_IFD
      #
      # Minolta MakerNote starts from 0 byte from the origin
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
        tagclass = Tag.find(tag.hex, Tag::MinoltaIFDTable)
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
