#
#  exifparser/tag.rb
#
#  Copyright (C) 2002 Ryuichi Tamura (r-tam@fsinet.or.jp)
#
#  $Revision: 1.3 $
#  $Date: 2003/04/27 14:02:39 $
#
require 'exifparser/utils'
require 'rational'

module Exif

  module Error
    class TagNotFound < StandardError; end
  end

  module Tag

    #
    # modules under this module provides '_formatData()' method,
    # which is invoked in Exif::Tag::Base#processData().
    #
    module Formatter

      #
      # convert data to unsigned byte(1 byte) value.
      #
      module UByte

        def format
          'Unsigned byte'
        end

        def _formatData(data)
          decode_ubytes(data)
        end

      end

      #
      # convert data to ASCII(1 byte) values.
      #
      module Ascii

        def format
          'Ascii'
        end

        def _formatData(data)
          data.delete("\000")
        end

      end

      #
      # convert data to unsigned short(2 byte) value.
      #
      module UShort

        def format
          'Unsigned short'
        end

        def _formatData(data)
          decode_ushort(data)
        end

      end

      #
      # convert data to unsigned long(4 byte) value.
      #
      module ULong

        def format
          'Unsigned long'
        end

        def _formatData(data)
          decode_ulong(data)
        end

      end

      #
      # convert data to unsigned rational(4+4 byte) value,
      # which in turn is converted to Rational object.
      #
      module URational

        def format
          'Unsigned rational'
        end

        def _formatData(data)
          a = decode_ulong(data[0,4])
          b = decode_ulong(data[4,4])
          return Rational(0,1) if b == 0
          Rational(a, b)
        end

      end

      #
      # convert data to some value by user-supplied method.
      # the client code should implement 'convert(data)' method.
      #
      module Undefined

        def format
          'Undefined'
        end

        def _formatData(data)
          if self.respond_to?(:_format0)
            _format0(data)
          else
            data.unpack("C*").collect{|e| e.to_i}
          end
        end

      end

      #
      # convert data to signed short value.
      #
      module SShort

        def format
          'Signed short'
        end

        def _formatData(data)
          decode_sshort(data)
        end

      end

      #
      # convert data to unsigned long(4 byte) value.
      #
      module SLong

        def format
          'Signed long'
        end

        def _formatData(data)
          decode_slong(data)
        end
      end

      #
      # convert data to signed rational (4+4 byte) value.
      #
      module SRational

        def format
          'Signed rational'
        end

        def _formatData(data)
          a = decode_slong(data[0,4])
          b = decode_slong(data[4,4])
          return Rational(0,1) if b == 0
          Rational(a, b)
        end

      end


    end # module Formatter

    #
    # maps number to size of one unit and the
    # corresponding formatter (defined below) module.
    #
    module Format

      Unit = {
        1 =>  [1, ::Exif::Tag::Formatter::UByte],
        2 =>  [1, ::Exif::Tag::Formatter::Ascii],
        3 =>  [2, ::Exif::Tag::Formatter::UShort],
        4 =>  [4, ::Exif::Tag::Formatter::ULong],
        5 =>  [8, ::Exif::Tag::Formatter::URational],
        #6 =>  [1, ::Exif::Tag::Formatter::SByte],
        7 =>  [1, ::Exif::Tag::Formatter::Undefined],
        8 =>  [2, ::Exif::Tag::Formatter::SShort],
        9 =>  [4, ::Exif::Tag::Formatter::SLong],
        10 => [8, ::Exif::Tag::Formatter::SRational],
        #11 => [4, Exif::Formatter::SFloat],
        #12 => [8, Exif::Formatter::DFloat]
      }

    end

    #
    # The base class that specifies common operations for tag data.
    # All the tag classes are derived from this, and client code
    # shoude use the public methods as interface.
    #
    class Base
      #
      # the argument 'byteorder' is either :intel or :motorola.
      # this is used when packing @data given after initialized.
      #
      def initialize(tagID, ifdname, count)
        @tagID = tagID
        @IFD = ifdname
        @count = count
        @data = nil
        @formatted = nil
        @pos = nil
        @dataPos = nil
      end
      attr_writer :data
      attr_accessor :pos, :dataPos
      attr_reader :tagID, :IFD, :count

      def processData
        @formatted = _formatData(@data)
      end

      #
      # return tag's value: simply returns @formatted as it is.
      #
      def value
        @formatted
      end

      #
      # String representation of tag's value
      # this is the default method that simply
      # sends Object#to_s to @formatted.
      # Subclasses may override this so that
      # it returns more human-readable form.
      #
      def to_s
        if self.is_a? Formatter::Undefined
          length = @formatted.length
          data = length > 8 ? @formatted[0, 8] : @formatted
          ret = ""
          data.each do |dat|
            ret += sprintf("%02X ", dat)
          end
          ret += %Q[...(#{length} bytes)] if length > data.length
          return ret
        else
          @formatted.to_s
        end
      end

      #
      # return tag's name
      #
      def name
        self.class.to_s.split("::")[-1]
      end

      #
      # format focal length
      #
      def formatFocalLength(f)
        if (f.abs < 10.0)
          str = "%.1f"%[f]
        else
          str = "%.0f"%[f]
        end
        "#{str}mm"
      end

      #
      # format exposure time
      #
      def formatExposureTime(ss)
        rss = 1.0/ss
        if (rss >= 3.0)
          str = "1/%.0f"%[rss]
        elsif (3.0 > rss && rss > 1.0)
          str = "1/%.1f"%[rss]
        elsif (ss == 1.0)
          str = "1.0"
        elsif (3.0 > ss && ss > 1.0)
          str = "%.1f"%[ss]
        else
          str = "%.0f"%[ss]
        end
        "#{str}sec."
      end

      #
      # format f number
      #
      def formatFNumber(f)
        if (f.abs < 10.0)
          str = "%.1f"%[f]
        else
          str = "%.0f"%[f]
        end
        "F#{str}"
      end

      #
      # format Latitude and Longitude
      #
      def formatLatLon(f)
        if f[2].to_f == 0.0
          sprintf("%d deg %.2f'",f[0],f[1])
        else
          sprintf("%d deg %d' %.2f\"",f[0],f[1],f[2])
        end
      end

      if not $DEBUG

      def inspect
        sprintf("#<%s ID=0x%04x, IFD=\"%s\" Name=\"%s\", Format=\"%s\", Count=\"%d\", Value=\"%s\">", self.class, @tagID, @IFD, self.name, self.format, self.count, self.value)
      end

      end

      private

      def partition_data(count)
        i = 0
        bytes = @data.size / count
        while @data[i]
          yield @data[i..i+bytes-1]
          i = i + bytes
        end
      end

    end

    ##
    ## the class for any unknown tags in
    ## IFD0, IFD1, GPSIFD, ExifIFD, InteroperabilityIFD
    ##
    class Unknown < Base
    end


    ##
    ## tags specific to Exif IFD.
    ## (see Exif standard 2.2 Section 4.6.3-A )
    ##

    #
    # 0x8769 - ExifIFDPointer
    #
    class ExifIFDPointer < Base
    end

    #
    # 0x8825 - GPSIFDPointer
    #
    class GPSIFDPointer < Base
    end

    #
    # 0xa005 - InteroperabilityIFDPointer
    #
    class InteroperabilityIFDPointer < Base
    end


    ##
    ## tags related TIFF Rev. 6.0 Attribute Information.
    ## (see Exif standard 2.2 Section 4.6.4 Table 3)
    ##

    module TIFF

      #
      # 0x0100 - ImageWidth
      #
      class ImageWidth < Base
      end

      #
      # 0x0101 - ImageLength
      #
      class ImageLength < Base
      end

      #
      # 0x0102 - BitsPerSample
      #
      class BitsPerSample < Base

        def processData
          @formatted = []
          partition_data(@count) do |data|
            @formatted.push _formatData(data)
          end
        end

        def to_s
          @formatted.join(",")
        end

      end

      #
      # 0x0103 - Compression
      #
      class Compression < Base

        def to_s
          case @formatted
          when 1
            'uncompressed'
          when 6
            'JPEG compression'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x0106 - PhotometricInterpretation
      #
      class PhotometricInterpretation < Base

        def to_s
          case @formatted
          when 2
            'RGB'
          when 6
            'YCbCr'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x0111 - StripOffsets
      #
      class StripOffsets < Base
      end

      #
      # 0x0112 - Orientation
      #
      class Orientation < Base
      end

      #
      # 0x0115 - SamplePerPixel
      #
      class SamplesPerPixel < Base
      end

      #
      # 0x0116 - RowsPerStrip
      #
      class RowsPerStrip < Base
      end

      #
      # 0x0117 - StripByteCounts
      #
      class StripByteCounts < Base
      end

      #
      # 0x011a - XResolution
      #
      class XResolution < Base
      end

      #
      # 0x011b - YResolution
      #
      class YResolution < Base
      end

      #
      # 0x011c - PlanarConfiguration
      #
      class PlanarConfiguration < Base

        def to_s
          case @formatted
          when 1
            'chunky format'
          when 2
            'planar format'
          else
            'unknown'
          end
        end

      end

      #
      # 0x0128 - ResolutionUnit
      #
      class ResolutionUnit < Base

        def to_s
          case @formatted
          when 2
            'inch'
          when 3
            'centimeter'
          else
            'unknown'
          end
        end

      end

      #
      # 0x0201 - JpegInterchangeFormat
      #
      class JpegInterchangeFormat < Base
      end

      #
      # 0x0202 - JpegInterchangeFormatLength
      #
      class JpegInterchangeFormatLength < Base
      end

      #
      # 0x0211 - YCbCrCoefficients
      #
      class YCbCrCoefficients < Base

        def processData
          @formatted = []
          partition_data(@count) do |data|
            @formatted.push _formatData(data)
          end
        end

        def to_s
          @formatted.join(",")
        end

      end

      #
      # 0x0212 - YCbCrSubSampling
      #
      class YCbCrSubSampling < Base

        def processData
          @formatted = []
          partition_data(@count) do |data|
            @formatted.push _formatData(data)
          end
        end

        def to_s
          case @formatted
          when [2,1]
            'YCbCr4:2:2'
          when [2,2]
            'YCbCr4:2:0'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x0213 - YCbCrPositioning
      #
      class YCbCrPositioning < Base

        def to_s
          case @formatted
          when 1
            'centered'
          when 2
            'co-sited'
          else
            'unknown'
          end
        end

      end

      #
      # 0x0214 - ReferenceBlackWhite
      #
      class ReferenceBlackWhite < Base
      end

      #
      # 0x010e - ImageDescription
      #
      class ImageDescription < Base
      end

      #
      # 0x010f - Make
      #
      class Make < Base
      end

      #
      # 0x0110 - Model
      #
      class Model < Base
      end

      #
      # 0x0112 - Orientation
      #
      class Orientation < Base

        def to_s
          case @formatted
          when 1
            "top - left"
          when 2
            "top - right"
          when 3
            "bottom - right"
          when 4
            "bottom - left"
          when 5
            "left - top"
          when 6
            "right - top"
          when 7
            "right - bottom"
          when 8
            "left - bottom"
          else
            "unknown"
          end
        end

      end

      #
      # 0x011a - XResolution
      #
      class XResolution < Base
      end

      #
      # 0x011b - YResolution
      #
      class YResolution < Base
      end

      #
      # 0x0128 - ResolutionUnit
      #
      class ResolutionUnit < Base

        def to_s
          case @formatted
          when 1
            "none"
          when 2
            "inch"
          when 3
            "centimeter"
          else
            "unknown"
          end
        end

      end

      #
      # 0x012D - TransferFunction
      #
      class TransferFunction < Base
      end

      #
      # 0x0131 - Software
      #
      class Software < Base
      end

      #
      # 0x0132 - DateTime
      #
      class DateTime < Base
      end

      #
      # 0x013B - Artist
      #
      class Artist < Base
      end

      #
      # 0x013E - WhitePoint
      #
      class WhitePoint < Base

        def processData
          @formatted = []
          partition_data(@count) do |data|
            @formatted.push _formatData(data)
          end
        end

        def to_s
          @formatted.join(",")
        end

      end

      #
      # 0x013f - PrimaryChromaticities
      #
      class PrimaryChromaticities < Base

        def processData
          @formatted = []
          partition_data(@count) do |data|
            @formatted.push _formatData(data)
          end
        end

        def to_s
          @formatted.join(",")
        end

      end

      #
      # 0x0211 - YCbCrCoefficients
      #
      class YCbCrCoefficients < Base

        def processData
          @formatted = []
          partition_data(@count) do |data|
            @formatted.push _formatData(data)
          end
        end

        def to_s
          @formatted.join(",")
        end

      end

      #
      # 0x0213 - YCbCrPositioning
      #
      class YCbCrPositioning < Base
      end

      #
      # 0x0214 - ReferenceBlackWhite
      #
      class ReferenceBlackWhite < Base

        def processData
          @formatted = []
          partition_data(@count) do |data|
            @formatted.push _formatData(data)
          end
        end

        def to_s
          @formatted.join(",")
        end

      end

      #
      # 0x8298 - Copyright
      #
      class Copyright < Base

        def to_s
          sep = @data.split("\0")
          photographer = sep[0]
          editor       = sep[1]
          "#{photographer} (Photographer) - #{editor} (Editor)"
        end

      end

    end

    ##
    ## Exif IFD tags
    ##

    module Exif

      #
      # 0x829a - ExposureTime
      #
      class ExposureTime < Base

        def to_s
          formatExposureTime(@formatted.to_f)
        end

      end

      #
      # 0x829d - FNumber
      #
      class FNumber < Base

        def to_s
          formatFNumber(@formatted.to_f)
        end

      end

      #
      # 0x8822 - ExposureProgram
      #
      class ExposureProgram < Base

        def to_s
          case @formatted
          when 0
            "Not defined"
          when 1
            "Manual"
          when 2
            "Normal program"
          when 3
            "Aperture priority"
          when 4
            "Shutter priority"
          when 5
            "Creative program (biased toward depth of field)"
          when 6
            "Action program (biased toward fast shutter speed)"
          when 7
            "Portrait mode (for closeup photos with the background out of focus)"
          when 8
            "Landscape mode (for landscape photos with the background in focus)"
          else
            "Unknown"
          end
        end

      end

      #
      # 0x8824 - SpectralSensitivity
      #
      class SpectralSensitivity < Base
      end

      #
      # 0x8828 - OECF
      #
      class OECF < Base
      end

      #
      # 0x8827 - ISOSpeedRatings
      #
      class ISOSpeedRatings < Base
      end

      #
      # 0x9000 - ExifVersion
      #
      class ExifVersion < Base

        def _format0(data)
          data
        end

        def to_s
          case @formatted
          when "0200"
            "Exif Version 2.0"
          when "0210"
            "Exif Version 2.1"
          when "0220"
            "Exif Version 2.2"
          when "0221"
            "Exif Version 2.21"
          else
            "Unknown Exif Version"
          end
        end

      end

      #
      # 0x9003 - DateTimeOriginal
      #
      class DateTimeOriginal < Base
      end

      #
      # 0x9004 - DateTimeDigitized
      #
      class DateTimeDigitized < Base
      end

      #
      # 0x9101 - ComponentsConfiguration
      #
      class ComponentsConfiguration < Base

        def _format0(data)
          data.unpack("C*").collect{|e| e.to_i}
        end

        def to_s
          case @formatted
          when [0x04,0x05,0x06,0x00]
            'RGB'
          when [0x01,0x02,0x03,0x00]
            'YCbCr'
          end
        end

      end

      #
      # 0x9102 - CompressedBitsPerPixel
      #
      class CompressedBitsPerPixel < Base

        def to_s
          "%.1fbits/pixel"%[@formatted.to_f]
        end

      end

        #
        # 0x9201 - ShutterSpeedValue
        #
      class ShutterSpeedValue < Base

        def to_s
          formatExposureTime(1.0/(2.0**(@formatted.to_f)))
        end

      end

      #
      # 0x9202 - ApertureValue
      #
      class ApertureValue < Base

        def to_s
          formatFNumber(Math.sqrt(2.0)**(@formatted.to_f))
        end

      end

      #
      # 0x9203 - BrightnessValue
      #
      class BrightnessValue < Base

        def to_s
          "%+.1f"%[@formatted.to_f]
        end

      end

      #
      # 0x9204 - ExposureBiasValue
      #
      class ExposureBiasValue < Base

        def to_s
          "%+.1f"%[@formatted.to_f]
        end

      end

      #
      # 0x9205 - MaxApertureValue
      #
      class MaxApertureValue < Base

        def to_s
          "F%.01f"%[Math.sqrt(2.0)**(@formatted.to_f)]
        end

      end

      #
      # 0x9206 - SubjectDistance
      #
      class SubjectDistance < Base
      end

      #
      # 0x9207 - MeteringMode
      #
      class MeteringMode < Base

        def to_s
          case @formatted
          when 1
            'Average'
          when 2
            'CenterWeightedAverage'
          when 3
            'Spot'
          when 4
            'MultiSpot'
          when 5
            'Pattern'
          when 6
            'Partial'
          when 255
            'other'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x9208 - LightSource
      #
      class LightSource < Base

        def to_s
          case @formatted
          when 0
            'Unknown'
          when 1
            'Daylight'
          when 2
            'Fluorescent'
          when 3
            'Tungsten'
          when 4
            'Flash'
          when 9
            'Fine weather'
          when 10
            'Croudy weather'
          when 11
            'Shade'
          when 12
            'Daylight fluorescent'
          when 13
            'Day white fluorescent'
          when 14
            'Cool white fluorescent'
          when 15
            'White fluorescent'
          when 17
            'Standard light A'
          when 18
            'Standard light B'
          when 19
            'Standard light C'
          when 20
            'D55'
          when 21
            'D65'
          when 22
            'D75'
          when 23
            'D50'
          when 24
            'ISO studio tungsten'
          when 255
            'other light source'
          else
            'reserved'
          end
        end

      end

      #
      # 0x9209 - Flash
      #
      class Flash < Base

        def to_s
          case @formatted
          when 0x0000
            'Flash did not fire.'
          when 0x0001
            'Flash fired.'
          when 0x0005
            'Strobe return light not detected.'
          when 0x0007
            'Strobe return light detected.'
          when 0x0009
            'Flash fired, compulsory flash mode.'
          when 0x000d
            'Flash fired, compulsory flash mode, return light not detected.'
          when 0x000f
            'Flash fired, compulsory flash mode, return light detected.'
          when 0x0010
            'Flash did not fire, compulsory flash mode.'
          when 0x0018
            'Flash did not fire, auto mode.'
          when 0x0019
            'Flash fired, auto mode.'
          when 0x001d
            'Flash fired, auto mode, return light not detected.'
          when 0x001f
            'Flash fired, auto mode, return light detected.'
          when 0x0020
            'No flash function.'
          when 0x0041
            'Flash fired, red-eye reduction mode.'
          when 0x0045
            'Flash fired, red-eye reduction mode, return light not detected.'
          when 0x0047
            'Flash fired, red-eye reduction mode, return light detected.'
          when 0x0049
            'Flash fired, compulsory flash mode.'
          when 0x004d
            'Flash fired, compulsory flash mode, return light not detected.'
          when 0x004f
            'Flash fired, compulsory flash mode, return light detected.'
          when 0x0059
            'Flash fired, auto mode, red-eye reduction mode.'
          when 0x005d
            'Flash fired, auto mode, return light not detected, red-eye reduction mode.'
          when 0x005f
            'Flash fired, auto mode, return light detected, red-eye reduction mode.'
          else
            "reserved"
          end
        end

      end

      #
      # 0x920a - FocalLength
      #
      class FocalLength < Base

        def to_s
          formatFocalLength(@formatted.to_f)
        end

      end

      #
      # 0x9214 - SubjectArea
      #
      class SubjectArea < Base

        def processData
          @formatted = []
          partition_data(@count) do |data|
            @formatted.push _formatData(data)
          end
        end

        def to_s
          case @count
          when 2
            "Coordinate - [%d, %d]"%[*@formatted]
          when 3
            "Circle - Center: [%d, %d], Diameter: %d"%[*@formatted]
          when 4
            "Rectanglar - Center: [%d, %d], Width: %d, Height: %d"%[*@formatted]
          else
            'Unknown'
          end
        end

      end

      #
      # 0x927c - MakerNote
      #
      class MakerNote < Base

        def data
          @data
        end

        def _format0(data)
          @data
        end

        def to_s
          sprintf("MakerNote data (%i bytes)", data.size)
        end

      end

      #
      # 0x9286 - UserComment
      #
      class UserComment < Base

        def to_s
          case @data[0..7]
          # ASCII
          when [0x41,0x53,0x43,0x49,0x49,0x0,0x0,0x0]
            @data[8..-1].pack("C*")
          # JIS
          when [0x4a,0x59,0x53,0x0,0x0,0x0,0x0,0x0]
            @data[8..-1].pack("C*")
          # Unicode
          when [0x55,0x4e,0x49,0x43,0x4f,0x44,0x45,0x0]
            @data[8..-1].pack("U*")
          when [0x0]*8
            @data[8..-1].pack("C*")
          else
            "unknown"
          end
        end

      end

      #
      # 0x9290 - SubsecTime < Base
      #
      class SubsecTime < Base
      end

      #
      # 0x9291 - SubsecTimeOriginal < Base
      #
      class SubsecTimeOriginal < Base
      end

      #
      # 0x9292 - SubsecTimeDigitized < Base
      #
      class SubsecTimeDigitized < Base
      end

      #
      # 0xa000 - FlashPixVersion
      #
      class FlashPixVersion < Base
        def _format0(data)
          data
        end

        def to_s
          case @formatted
          when "0100"
            "FlashPix Version 1.0"
          else
            "Unknown FlashPix Version"
          end
        end

      end

      #
      # 0xa001 - ColorSpace
      #
      class ColorSpace < Base

        def to_s
          case @formatted
          when 1
            'sRGB'
          when 65535
            'Uncalibrated'
          else
            'Unknown: #{@formatted}'
          end
        end

      end

      #
      # 0xa002 - PixelXDimension
      #
      class PixelXDimension < Base

        def processData
          case self.byte_order
          when :intel
            @formatted = decode_ushort(@data[0,2])
          when :motorola
            @formatted = decode_ushort(@data[2,2])
          end
        end

      end

      #
      # 0xa003 - PixelYDimension
      #
      class PixelYDimension < Base

        def processData
          case self.byte_order
          when :intel
            @formatted = decode_ushort(@data[0,2])
          when :motorola
            @formatted = decode_ushort(@data[2,2])
          end
        end

      end

      #
      # 0xa004 - RelatedSoundFile
      #
      class RelatedSoundFile < Base
      end

      #
      # 0xa20b - FlashEnergy
      #
      class FlashEnergy < Base
      end

      #
      # 0xa20c - SpatialFrequencyResponse
      #
      class SpatialFrequencyResponse < Base
      end

      #
      # 0xa20e - FocalPlaneXResolution
      #
      class FocalPlaneXResolution < Base
      end

      #
      # 0xa20f - FocalPlaneYResolution
      #
      class FocalPlaneYResolution < Base
      end

      #
      # 0xa210 - FocalPlaneResolutionUnit
      #
      class FocalPlaneResolutionUnit < Base

        def to_s
          case @formatted
          when 1
            'No unit'
          when 2
            'Inch'
          when 3
            'Centimeter'
          else
            'Unknown'
          end
        end

      end

      #
      # 0xa214 - SubjectLocation
      #
      class SubjectLocation < Base

        def processData
          @formatted = []
          partition_data(@count) do |data|
            @formatted.push _formatData(data)
          end
        end

        def to_s
          "[%d, %d]"%[*@formatted]
        end

      end

      #
      # 0xa215 - ExposureIndex
      #
      class ExposureIndex < Base
      end

      #
      # 0xa217 - SensingMethod
      #
      class SensingMethod < Base

        def to_s
          case @formatted
          when 2
            'One-chip color area sensor'
          else
            'Unknown'
          end
        end

      end

      #
      # 0xa300 - FileSource
      #
      class FileSource < Base
        def _format0(data)
          data[0]
        end

        def to_s
          case @formatted
          when 0x03
            'Digital still camera'
          else
            'Unknown'
          end
        end

      end

      #
      # 0xa301 - SceneType
      #
      class SceneType < Base

        def _format0(data)
          data[0]
        end

        def to_s
          case @formatted
          when 0x01
            'Directory photographed'
          else
            'Unknown'
          end
        end

      end

      #
      # 0xa302 - CFAPattern
      #
      class CFAPattern < Base
      end

      #
      # 0xa401 - CustomRendered
      #
      class CustomRendered < Base
        def to_s
          case @formatted
          when 0
            'Normal process'
          when 1
            'Custom process'
          else
            'reserved'
          end
        end
      end

      #
      # 0xa402 - ExposureMode
      #
      class ExposureMode < Base
        def to_s
          case @formatted
          when 0
            'Auto exposure'
          when 1
            'Manual exposure'
          when 2
            'Auto bracket'
          else
            'reserved'
          end
        end
      end

      #
      # 0xa403 - WhiteBalance
      #
      class WhiteBalance < Base
        def to_s
          case @formatted
          when 0
            'Auto white balance'
          when 1
            'Manual white balance'
          else
            'reserved'
          end
        end
      end

      #
      # 0xa404 - DigitalZoomRatio
      #
      class DigitalZoomRatio < Base
        def to_s
          n = @formatted.numerator
          d = @formatted.denominator
          n == 0 ? 'None' : "%.1f"%[n.to_f/d.to_f]
        end
      end

      #
      # 0xa405 - FocalLengthIn35mmFilm
      #
      class FocalLengthIn35mmFilm < Base
        def to_s
          @formatted == 0 ? 'Unknown' : formatFocalLength(@formatted)
        end
      end

      #
      # 0xa406 - SceneCaptureType
      #
      class SceneCaptureType < Base
        def to_s
          case @formatted
          when 0
            'Standard'
          when 1
            'Landscape'
          when 2
            'Portrait'
          when 3
            'Nigit scene'
          else
            'reserved'
          end
        end
      end

      #
      # 0xa407 - GaincControl
      #
      class GainControl < Base
        def to_s
          case @formatted
          when 0
            'None'
          when 1
            'Low gain up'
          when 2
            'High gain up'
          when 3
            'Low gain down'
          when 4
            'High gain down'
          else
            'reserved'
          end
        end
      end

      #
      # 0xa408 - Contrast
      #
      class Contrast < Base
        def to_s
          case @formatted
          when 0
            'Normal'
          when 1
            'Soft'
          when 2
            'Hard'
          else
            'reserved'
          end
        end
      end

      #
      # 0xa409 - Saturation
      #
      class Saturation < Base
        def to_s
          case @formatted
          when 0
            'Normal'
          when 1
            'Low saturation'
          when 2
            'High saturation'
          else
            'reserved'
          end
        end
      end

      #
      # 0xa40a - Sharpness
      #
      class Sharpness < Base
        def to_s
          case @formatted
          when 0
            'Normal'
          when 1
            'Soft'
          when 2
            'Hard'
          else
            'reserved'
          end
        end
      end

      #
      # 0xa40b - DeviceSettingDescription
      #
      class DeviceSettingDescription < Base
      end

      #
      # 0xa40c - SubjectDistanceRange
      #
      class SubjectDistanceRange < Base
        def to_s
          case @formatted
          when 0
            'Unknown'
          when 1
            'Macro'
          when 2
            'Close view'
          when 3
            'Distant view'
          else
            'reserved'
          end
        end
      end

      #
      # 0xa420 - ImageUniqueID
      #
      class ImageUniqueID < Base
      end

    end

    ##
    ## GPS IFD tags
    ##

    module GPS

      #
      # 0x0000 - GPSVersionID
      #
      # type : byte
      # count: 4
      #
      class GPSVersionID < Base

        def to_s
          case @formatted
          when [2,2,0,0]
            "Version 2.2"
          else
            "Unknown"
          end
        end

      end

      #
      # 0x0001 - GPSLatitudeRef
      #
      class GPSLatitudeRef < Base

        def to_s
          case @formatted
          when 'N'
            'North latitude'
          when 'S'
            'South latitude'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x0002 - GPSLatitude
      #
      class GPSLatitude < Base

        def processData
          @formatted = []
          partition_data(@count) do |data|
            @formatted.push _formatData(data)
          end
        end

        def to_s
          formatLatLon @formatted
        end

      end

      #
      # 0x0003 - GPSLongitudeRef
      #
      class GPSLongitudeRef < Base

        def to_s
          case @formatted
          when 'E'
            'East longitude'
          when 'W'
            'West longitude'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x0004 - GPSLongitude
      #
      class GPSLongitude < Base

        def processData
          @formatted = []
          partition_data(@count) do |data|
            @formatted.push _formatData(data)
          end
        end

        def to_s
          formatLatLon @formatted
        end

      end

      #
      # 0x0005 - GPSAltitudeRef
      #
      class GPSAltitudeRef < Base

        def to_s
          case @formatted[0]
          when 0
            'Sea level'
          when 1
            'Sea level(negative value)'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x0006 - GPSAltitude
      #
      class GPSAltitude < Base
      end

      #
      # 0x0007 - GPSTimeStamp
      #
      class GPSTimeStamp < Base

        def processData
          @formatted = []
          partition_data(@count) do |data|
            @formatted.push _formatData(data)
          end
        end

        def to_s
          @formatted.join(",")
        end

      end

      #
      # 0x0008 - GPSSatelites
      #
      class GPSSatelites < Base
      end

      #
      # 0x0009 -  GPSStatus
      #
      class GPSStatus < Base

        def to_s
          case @formatted
          when 'A'
            'Measurement in progress'
          when 'V'
            'Measurement in interoperability'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x000A - GPSMeasureMode
      #
      class GPSMeasureMode < Base

        def to_s
          case @formatted
          when '2'
            '2-dimensional measurement'
          when '3'
            '3-dimensional measurement'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x000B - GPSDOP
      #
      class GPSDOP < Base
      end

      #
      # 0x000C - GPSSpeedRef
      #
      class GPSSpeedRef < Base

        def to_s
          case @formatted
          when 'K'
            'Kilometers per hour'
          when 'M'
            'Miles per hour'
          when 'N'
            'Knots'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x000D - GPSSpeed
      #
      class GPSSpeed < Base
      end

      #
      # 0x000E - GPSTrackRef
      #
      class GPSTrackRef < Base

        def to_s
          case @formatted
          when 'T'
            'True direction'
          when 'M'
            'Magnetic direction'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x000F - GPSTrack
      #
      class GPSTrack < Base
      end

      #
      # 0x0010 - GPSImgDirectionRef
      #
      class GPSImgDirectionRef < Base

        def to_s
          case @formatted
          when 'T'
            'True direction'
          when 'M'
            'Magnetic direction'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x0011 - GPSImgDirection
      #
      class GPSImgDirection < Base
      end

      #
      # 0x0012 - GPSMapDatum
      #
      class GPSMapDatum < Base
      end

      #
      # 0x0013 - GPSDestLatitudeRef
      #
      class GPSDestLatitudeRef < Base

        def to_s
          case @formatted
          when 'N'
            'North latitude'
          when 'S'
            'South latitude'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x0014 - GPSDestLatitude
      #
      class GPSDestLatitude < Base

        def processData
          @formatted = []
          partition_data(@count) do |data|
            @formatted.push _formatData(data)
          end
        end

        def to_s
          formatLatLon @formatted
        end

      end

      #
      # 0x0015 - GPSDestLongitudeRef
      #
      class GPSDestLongitudeRef < Base

        def to_s
          case @formatted
          when 'E'
            'East longitude'
          when 'W'
            'West longitude'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x0016 - GPSDestLongitude
      #
      class GPSDestLongitude < Base

        def processData
          @formatted = []
          partition_data(@count) do |data|
            @formatted.push _formatData(data)
          end
        end

        def to_s
          formatLatLon @formatted
        end

      end

      #
      # 0x0017 - GPSDestBearingRef
      #
      class GPSDestBearingRef < Base

        def to_s
          case @formatted
          when 'T'
            'True direction'
          when 'M'
            'Magnetic direction'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x0018 - GPSDestBearing
      #
      class GPSDestBearing < Base
      end

      #
      # 0x0019 - GPSDestDistanceRef
      #
      class GPSDestDistanceRef < Base

        def to_s
          case @formatted
          when 'K'
            'Kilometers'
          when 'M'
            'Miles'
          when 'N'
            'Knots'
          else
            'Unknown'
          end
        end

      end

      #
      # 0x001A
      #
      class GPSDestDistance < Base
      end

      #
      # 0x001B
      #
      class GPSProcessingMethod < Base
      end

      #
      # 0x001C
      #
      class GPSAreaInformation < Base
      end

      #
      # 0x001D
      #
      class GPSDateStamp < Base
      end

      #
      # 0x001E
      #
      class GPSDifferential < Base
        def to_s
          case @formatted
          when 0
            'Measurement without differential correction'
          when 1
            'Differential correction applied'
          else
            'Unknown'
          end
        end
      end

    end

    ##
    ## Interoperability IFD tags
    ##

    module Interoperability

      #
      # 0x0001 - InteroperabilityIndex
      #
      class InteroperabilityIndex < Base
      end

      #
      # 0x0002 - InteroperabilityVersion
      #
      class InteroperabilityVersion < Base
      end

      #
      # 0x1000 - RelatedImageFileFormat
      #
      class RelatedImageFileFormat
      end

      #
      # 0x1001 - RelatedImageWidth
      #
      class RelatedImageWidth < Base
      end

      #
      # 0x1002 - RelatedImageLength
      #
      class RelatedImageLength < Base
      end

    end


    #
    # Hash tables that maps tag ID to the corresponding class.
    #

    ExifSpecific = {
      0x8769 => ExifIFDPointer,
      0x8825 => GPSIFDPointer,
      0xa005 => InteroperabilityIFDPointer
    }

    TIFFAttributes = {
      0x0100 => TIFF::ImageWidth,
      0x0101 => TIFF::ImageLength,
      0x0102 => TIFF::BitsPerSample,
      0x0103 => TIFF::Compression,
      0x0106 => TIFF::PhotometricInterpretation,
      0x010E => TIFF::ImageDescription,
      0x010F => TIFF::Make,
      0x0110 => TIFF::Model,
      0x0111 => TIFF::StripOffsets,
      0x0112 => TIFF::Orientation,
      0x0115 => TIFF::SamplesPerPixel,
      0x0116 => TIFF::RowsPerStrip,
      0x0117 => TIFF::StripByteCounts,
      0x011A => TIFF::XResolution,
      0x011B => TIFF::YResolution,
      0x011C => TIFF::PlanarConfiguration,
      0x0128 => TIFF::ResolutionUnit,
      0x012D => TIFF::TransferFunction,
      0x0131 => TIFF::Software,
      0x0132 => TIFF::DateTime,
      0x013B => TIFF::Artist,
      0x013E => TIFF::WhitePoint,
      0x013F => TIFF::PrimaryChromaticities,
      0x0201 => TIFF::JpegInterchangeFormat,
      0x0202 => TIFF::JpegInterchangeFormatLength,
      0x0211 => TIFF::YCbCrCoefficients,
      0x0212 => TIFF::YCbCrSubSampling,
      0x0213 => TIFF::YCbCrPositioning,
      0x0214 => TIFF::ReferenceBlackWhite,
      0x8298 => TIFF::Copyright,
    }

    #
    # ExifStandard 2.2, Section 4.6.8-A
    #
    IFD0Table = TIFFAttributes.update ExifSpecific

    def IFD0Table.name
      "IFD0"
    end

    #
    # ExifStandard 2.2, Section 4.6.8-B
    #
    IFD1Table = IFD0Table.dup

    def IFD1Table.name
      "IFD1"
    end


    ExifIFDTable = {
      0x829a => Exif::ExposureTime,
      0x829d => Exif::FNumber,
      0x8822 => Exif::ExposureProgram,
      0x8824 => Exif::SpectralSensitivity,
      0x8827 => Exif::ISOSpeedRatings,
      0x8828 => Exif::OECF,
      0x9000 => Exif::ExifVersion,
      0x9003 => Exif::DateTimeOriginal,
      0x9004 => Exif::DateTimeDigitized,
      0x9101 => Exif::ComponentsConfiguration,
      0x9102 => Exif::CompressedBitsPerPixel,
      0x9201 => Exif::ShutterSpeedValue,
      0x9202 => Exif::ApertureValue,
      0x9203 => Exif::BrightnessValue,
      0x9204 => Exif::ExposureBiasValue,
      0x9205 => Exif::MaxApertureValue,
      0x9206 => Exif::SubjectDistance,
      0x9207 => Exif::MeteringMode,
      0x9208 => Exif::LightSource,
      0x9209 => Exif::Flash,
      0x920a => Exif::FocalLength,
      0x9214 => Exif::SubjectArea,
      0x927c => Exif::MakerNote,
      0x9286 => Exif::UserComment,
      0x9290 => Exif::SubsecTime,
      0x9291 => Exif::SubsecTimeOriginal,
      0x9292 => Exif::SubsecTimeDigitized,
      0xa000 => Exif::FlashPixVersion,
      0xa001 => Exif::ColorSpace,
      0xa002 => Exif::PixelXDimension,
      0xa003 => Exif::PixelYDimension,
      0xa004 => Exif::RelatedSoundFile,
      0xa005 => InteroperabilityIFDPointer,
      0xa20b => Exif::FlashEnergy,
      0xa20c => Exif::SpatialFrequencyResponse,
      0xa20e => Exif::FocalPlaneXResolution,
      0xa20f => Exif::FocalPlaneYResolution,
      0xa210 => Exif::FocalPlaneResolutionUnit,
      0xa214 => Exif::SubjectLocation,
      0xa215 => Exif::ExposureIndex,
      0xa217 => Exif::SensingMethod,
      0xa300 => Exif::FileSource,
      0xa301 => Exif::SceneType,
      0xa302 => Exif::CFAPattern,
      0xa401 => Exif::CustomRendered,
      0xa402 => Exif::ExposureMode,
      0xa403 => Exif::WhiteBalance,
      0xa404 => Exif::DigitalZoomRatio,
      0xa405 => Exif::FocalLengthIn35mmFilm,
      0xa406 => Exif::SceneCaptureType,
      0xa407 => Exif::GainControl,
      0xa408 => Exif::Contrast,
      0xa409 => Exif::Saturation,
      0xa40a => Exif::Sharpness,
      0xa40b => Exif::DeviceSettingDescription,
      0xa40c => Exif::SubjectDistanceRange,
      0xa420 => Exif::ImageUniqueID
    }

    def ExifIFDTable.name
      "Exif"
    end

    GPSIFDTable = {
      0x0000 => GPS::GPSVersionID,
      0x0001 => GPS::GPSLatitudeRef,
      0x0002 => GPS::GPSLatitude,
      0x0003 => GPS::GPSLongitudeRef,
      0x0004 => GPS::GPSLongitude,
      0x0005 => GPS::GPSAltitudeRef,
      0x0006 => GPS::GPSAltitude,
      0x0007 => GPS::GPSTimeStamp,
      0x0008 => GPS::GPSSatelites,
      0x000a => GPS::GPSMeasureMode,
      0x000b => GPS::GPSDOP,
      0x000c => GPS::GPSSpeedRef,
      0x000d => GPS::GPSSpeed,
      0x000e => GPS::GPSTrackRef,
      0x000f => GPS::GPSTrack,
      0x0010 => GPS::GPSImgDirectionRef,
      0x0011 => GPS::GPSImgDirection,
      0x0012 => GPS::GPSMapDatum,
      0x0013 => GPS::GPSDestLatitudeRef,
      0x0014 => GPS::GPSDestLatitude,
      0x0015 => GPS::GPSDestLongitudeRef,
      0x0016 => GPS::GPSDestLongitude,
      0x0017 => GPS::GPSDestBearingRef,
      0x0018 => GPS::GPSDestBearing,
      0x0019 => GPS::GPSDestDistanceRef,
      0x001A => GPS::GPSDestDistance,
      0x001B => GPS::GPSProcessingMethod,
      0x001C => GPS::GPSAreaInformation,
      0x001D => GPS::GPSDateStamp,
      0x001E => GPS::GPSDifferential
    }

    def GPSIFDTable.name
      "GPS"
    end

    InteroperabilityIFDTable = {
      0x0001 => Interoperability::InteroperabilityIndex,
      0x0002 => Interoperability::InteroperabilityVersion,
      0x1000 => Interoperability::RelatedImageFileFormat,
      0x1001 => Interoperability::RelatedImageWidth,
      0x1002 => Interoperability::RelatedImageLength
    }

    def InteroperabilityIFDTable.name
      "Interoperability"
    end


    module_function

    def find(tagid, table)
      table[tagid] or ::Exif::Tag::Unknown
    end

  end

end
