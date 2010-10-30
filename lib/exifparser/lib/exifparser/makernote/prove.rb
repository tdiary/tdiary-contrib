#
#
#    exifparser/makernote/prove.rb -
#
#   Copyright (C) 2002 Ryuichi Tamura (r-tam@fsinet.or.jp)
#
#   $Revision: 1.1.1.1 $
#   $Date: 2002/12/16 07:59:00 $
#
require 'exifparser/makernote/fujifilm'
require 'exifparser/makernote/olympus'
require 'exifparser/makernote/canon'
require 'exifparser/makernote/nikon'
require 'exifparser/makernote/nikon2'
require 'exifparser/makernote/minolta'
require 'exifparser/makernote/sigma'

module Exif

  module MakerNote

    class NotSupportedError < RuntimeError; end

    module_function

    def prove(data, tag_make=nil, tag_model=nil)

      make = tag_make == nil ? '' : tag_make.to_s.upcase
      model = tag_model == nil ? '' : tag_model.to_s.upcase

      #
      # Identifier for OLYMPUS
      #
      if data[0..5] == "OLYMP\000"
        return Olympus
      #
      # Identifier for FUJIFILM
      #
      elsif data[0..7] == "FUJIFILM"
        return Fujifilm

      #
      # Identifier for Nikon
      #

      elsif make[0..4] == 'NIKON'
        if data[0..5] == "Nikon\000"
          if data[6] == 0x01 && data[7] == 0x00
            return Nikon
          end
        end
        return Nikon2

      #
      # Canon
      #
      elsif make[0..4] == 'CANON'
        return Canon

      #
      # Minolta
      #
      elsif make[0..6] == 'MINOLTA'
        return Minolta

      #
      # Sigma
      #
      elsif make[0..4] == 'SIGMA'
        return Sigma

      end

      #
      # If none above is applied, raises exception,
      # which will be caught by caller's rescue statement.
      #
      raise NotSupportedError
    end
    module_function :prove

  end

end
