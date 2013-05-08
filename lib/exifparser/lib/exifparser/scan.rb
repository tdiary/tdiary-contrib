#
#    exifparser/scan.rb
#
#    Copyright (C) 2002 Ryuichi Tamura (r-tam@fsinet.or.jp)
#
#    $Revision: 1.2 $
#    $Date: 2003/04/20 19:58:31 $
#
#
require 'exifparser/utils'
require 'exifparser/tag'
require 'exifparser/makernote/prove'

module Exif

  class Scanner

    def initialize(fin)
      @fin = fin.binmode
      @result = {}
      @tiffHeader0 = nil  # origin at which TIFF header begins
      @byteOrder_module = nil
    end
    attr_reader :result

    def finish
      @fin.close
    end

    def scan
      tic = Time.now if $DEBUG
      #
      # check soi (start of image)
      #
      @fin.pos = 0
      unless get_soi == 0xFFD8
        raise RuntimeError, 'not JPEG format'
      end

      #
      # seek app1 (EXIF signature)
      #
      begin
        marker = get_marker
        break if (marker == 0xFFE1)
        size = get_marker_datasize
        @fin.seek(size - 2, IO::SEEK_CUR)
      end while (!@fin.eof?)

      if marker != 0xFFE1
        raise RuntimeError, 'not EXIF format'
      end

      #
      # get app1 Data size
      #
      @result[:app1DataSize] = get_marker_datasize()
      curpos = @fin.pos
      @result[:app1Data] = fin_read_n(@result[:app1DataSize])
      @fin.pos = curpos

      #
      # EXIF header must be exactly "Exif\000\000", but some model
      # does not provide correct one. So we relax the condition.
      #
      if (h = exif_identifier()) !~ /\AExif\000/
        raise RuntimeError, "Invalid EXIF header: #{h}"
      end

      #
      # examine TIFF header
      #
      @tiffHeader0, tiff_header = get_tiff_header()

      #
      # get byte order
      #
      case tiff_header[0,2]
      when "MM"
        @byteOrder_module = Utils::Decode::Motorola
      when "II"
        @byteOrder_module = Utils::Decode::Intel
      else
        raise RuntimeError, "Unknown byte order"
      end
      self.extend @byteOrder_module
      @result[:offset_IFD0] = decode_ulong(tiff_header[4..-1])

      #
      # IFD0
      #
      @fin.pos = @tiffHeader0 + @result[:offset_IFD0]
      @result[:IFD0] = []
      scan_IFD(Tag::IFD0Table, Tag::IFD0Table.name) do |tag|
        @result[:IFD0].push tag
      end

      #
      # IFD1
      #
      @result[:IFD1] = []
      next_ifd = decode_ulong(fin_read_n(4))
      if next_ifd > 0
        @fin.pos = @tiffHeader0 + next_ifd
        scan_IFD(Tag::IFD1Table, Tag::IFD1Table.name) do |tag|
          @result[:IFD1].push tag
        end
      end

      #
      # GPS IFD
      #
      @result[:GPS] = []
      found = @result[:IFD0].find{ |e|
        e.class == Tag::GPSIFDPointer
      }
      if found
        @result[:offset_GPS] = found.processData
        @fin.pos = @tiffHeader0 + @result[:offset_GPS]
        scan_IFD(Tag::GPSIFDTable, Tag::GPSIFDTable.name) do |tag|
          @result[:GPS].push tag
        end
      end

      #
      # Exif IFD
      #
      @result[:Exif] = []
      found = @result[:IFD0].find{ |e|
        e.class == Tag::ExifIFDPointer
      }
      if found
        @result[:offset_Exif] = found.processData
        @fin.pos = @tiffHeader0 + @result[:offset_Exif]
        scan_IFD(Tag::ExifIFDTable, Tag::ExifIFDTable.name) do |tag|
          @result[:Exif].push tag
        end
      end

      #
      # Interoperability subIFD
      #
      @result[:Interoperability] = []
      found = @result[:Exif].find {|e|
        e.class == Tag::InteroperabilityIFDPointer
      }
      if found
        @result[:offset_InteroperabilityIFD] = found.processData
        @fin.pos = @tiffHeader0 + @result[:offset_InteroperabilityIFD]
        scan_IFD(Tag::InteroperabilityIFDTable, Tag::InteroperabilityIFDTable.name) do |tag|
          @result[:Interoperability].push tag
        end
      end

      #
      # MakerNote subIFD
      #
      @result[:MakerNote]=[]
      found = @result[:Exif].find {|e| e.class == Tag::Exif::MakerNote }
      if (found)
        begin
          # Because some vendors do not put any identifier in the header,
          # we try to find which model is by seeing Tag::TIFF::Make, Tag::TIFF::Model.
          make = @result[:IFD0].find {|e| e.class == Tag::TIFF::Make}
          model = @result[:IFD0].find {|e| e.class == Tag::TIFF::Model}
          # prove the maker
          makernote_class = Exif::MakerNote.prove(found.data, make, model)
          # set file pointer to the position where the tag was found.
          @fin.pos = found.pos
          makernote = makernote_class.new(@fin, @tiffHeader0, found.dataPos, @byteOrder_module)
          makernote.scan_IFD do |tag|
            @result[:MakerNote].push tag
          end
        rescue MakerNote::NotSupportedError
        rescue Exception # what to do?
          if $DEBUG
            raise $!
          end
        end
      end

      #
      # get thumbnail
      #
      if !@result[:IFD1].empty?
        format = @result[:IFD1].find do |e|
          e.class == Tag::TIFF::Compression
        end.value
        unless format == 6
          raise NotImplementedError, "Sorry, thumbnail of other than JPEG format is not supported."
        end
        thumbStart = @result[:IFD1].find do |e|
          e.class == Exif::Tag::TIFF::JpegInterchangeFormat
        end.value
        thumbLen = @result[:IFD1].find do |e|
          e.class == Exif::Tag::TIFF::JpegInterchangeFormatLength
        end.value
        @fin.pos = @tiffHeader0 + thumbStart
        # check JPEG soi maker
        if get_soi != 0xFFD8
          raise RuntimeError, 'not JPEG format'
        end
        @fin.pos = @fin.pos - 2
        # now read thumbnail image
        @result[:Thumbnail] = @fin.read(thumbLen)
      end

      # turn on if $DEBUG
      toc = Time.now if $DEBUG
      puts(sprintf("scan time: %1.4f sec.", toc-tic)) if $DEBUG
    end

    private

    def fin_read_n(n)
      @fin.read(n)
    end

    def scan_IFD(tagTable, ifdname)
      num_dirs = decode_ushort(fin_read_n(2))
      1.upto(num_dirs) {
        curpos_tag = @fin.pos
        tag = parseTagID(fin_read_n(2))
        tagclass = Tag.find(tag.hex, tagTable)
        unit, formatter = Tag::Format::Unit[decode_ushort(fin_read_n(2))]
        count = decode_ulong(fin_read_n(4))
        tagdata = fin_read_n(4)
        next if formatter == nil
        obj = tagclass.new(tag, ifdname, count)
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

    def get_soi
      (@fin.read(1).unpack("C*")[0]) << 8 | (@fin.read(1).unpack("C*")[0])
    end

    def get_marker
      (@fin.read(1).unpack("C*")[0]) << 8 | (@fin.read(1).unpack("C*")[0])
    end

    def get_marker_datasize
      (@fin.read(1).unpack("C*")[0]) << 8 | (@fin.read(1).unpack("C*")[0])
    end

    def exif_identifier
      @fin.read(6)
    end

    def get_tiff_header
      pos = @fin.pos
      [pos, fin_read_n(8)]
    end

    def eoi
      @fin.seek(-2, IO::SEEK_END)
      @fin.read(2)
    end

  end

end
