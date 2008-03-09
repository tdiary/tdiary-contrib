#
#  exifparser/thumbnail.rb -
#
#  Copyright (C) 2002 Ryuichi Tamura (r-tam@fsinet.or.jp)
#
#  $Revision: 1.1.1.1 $
#  $Date: 2002/12/16 07:59:00 $
#

module Exif

  class Parser

    alias orig_thumbnail thumbnail

    #
    # redefine method.
    #
    def thumbnail
      Thumbnail.new(@result[:IFD1], @data)
    end

  end

  #
  # APIs are subject to change.
  #
  class Thumbnail

    def initialize(ifd1, data)
      @ifd1 = ifd1
      @data = data
    end

    def size
      @data.size
    end

    def write(dest)
      dest << @data
    end

    def width
      search_tag('ImageWidth')
    end

    def height
      search_tag('ImageLength')
    end
    alias length height

    def bits_per_sample
      search_tag('BitsPerSample')
    end

    def compression
      search_tag('Compression')
    end

    def photometric_interpretation
      search_tag('PhotometricInterpretation')
    end

    def strip_offsets
      search_tag('StripOffsets')
    end

    private

    def search_tag(tag)
      @ifd1.find { |t| t.name == tag }
    end

  end

end
