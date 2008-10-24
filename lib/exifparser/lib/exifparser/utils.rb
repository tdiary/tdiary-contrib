#
#   exifparser/utils.rb -
#
#   Copyright (C) 2002 Ryuichi Tamura (r-tam@fsinet.or.jp)
#
#    $Revision: 1.1.1.1 $
#    $Date: 2002/12/16 07:59:00 $
#

module Exif

  #
  # utility module that will be included in some classes.
  #
  module Utils

    module Decode

      module Motorola

        def byte_order
          :motorola
        end

        def decode_ubytes(str)
          str.unpack('C*')
        end

        def decode_ushort(str)
          str[0,2].unpack('n').first
        end

        def decode_ulong(str)
          str[0,4].unpack('N').first
        end

        def decode_sshort(str)
          str[0,2].unpack('n').pack('s').unpack('s').first
        end

        def decode_slong(str)
          str[0,4].unpack('N').pack('l').unpack('l').first
        end

        def parseTagID(str)
          sprintf("0x%02x%02x", *(str.unpack("C*")))
        end


      end

      module Intel

        def byte_order
          :intel
        end

        def decode_ubytes(str)
          str.unpack('C*')
        end

        def decode_ushort(str)
          str[0,2].unpack('v').first
        end

        def decode_ulong(str)
          str[0,4].unpack('V').first
        end

        def decode_sshort(str)
          str[0,2].unpack('s').first
        end

        def decode_slong(str)
          str[0,4].unpack('l').first
        end

        def parseTagID(str)
          "0x" + str.unpack("C*").reverse.collect{ |e| sprintf("%02x", e) }.join("")
        end

      end

    end

  end

end
