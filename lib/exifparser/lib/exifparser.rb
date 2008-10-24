#
#
#=  exifparser.rb - Exif tag parser written in pure ruby
#
#Author:: Ryuchi Tamura (r-tam@fsinet.or.jp)
#Copyright:: Copyright (C) 2002 Ryuichi Tamura.
#
# $Id: exifparser.rb,v 1.1.1.1 2002/12/16 07:59:00 tam Exp $
#
#== INTRODUCTION
#
#There are 2 classes you work with. ExifParser class is
#the Exif tag parser that parses all tags defined EXIF-2.2 standard,
#and many of extension tags uniquely defined by some digital equipment
#manufacturers. Currently, part of tags defined by FujiFilm, and
#Olympus is supported. After initialized with the path to image file
#of EXIF format, ExifParser will provides which tags are available in
#the image, and how you work with them.
#
#Tags availble from ExifParser is objects defined under Exif::Tag module,
#with its name being the class name. For example if you get "Make" tag
#from ExifParser, it is Exif::Tag::DateTime object. Inspecting it looks
#following:
#
# #<Exif::Tag::TIFF::Make ID=0x010f, IFD="IFD0" Name="Make", Format="Ascii" Value="FUJIFILM">
#
#here, ID is Tag ID defined in EXIF-2.2 standard, IFD is the name of
#Image File Directory, Name is String representation of tag ID, Format is
#string that shows how the data is formatted, and Value is the value of
#the tag. This is retrieved by Exif::Tag::Make#value.
#
#Another example. If you want to know whether flash was fired when the image
#was generated, ExifParser returns Exif::Tag::Flash object:
#
# tag = exif['Flash']
# p tag
# => #<Exif::Tag::Exif::Flash ID=0x9209, IFD="Exif" Name="Flash", Format="Unsigned short" Value="1">
# p tag.value
# => 1
#
#It may happen that diffrent IFDs have the same tag name. In this case,
#use Exif#tag(tagname, IFD)
#
#The value of the tag above, 1, is not clearly understood
#(supposed to be 'true', though). Exif::Tag::Flash#to_s will provides
#more human-readable form as String.
#
# tag.to_s #=> "Flash fired."
#
#many of these sentences are cited from Exif-2.2 standard.
#
#== USAGE
# require 'exifparser'
#
# exif = ExifParser.new("fujifilm.jpg")
#
# 1. get a tag value by its name('Make') or its ID (0x010f)
# exif['Make'] #=> 'FUJIFILM'
# exif[0x010f] #=> 'FUJIFILM'
#
# if the specified tag is not found, nil is returned.
#
# 2. to see the image has the value of specified tag
# exif.tag?('DateTime') #=> true
# exif.tag?('CameraID') #=> false
#
# 3. get all the tags contained in the image.
#
# exif.tags
#
# or, if you want to know all the tags defined in specific IFD,
#
# exif.tags(:IFD0) # get all the tags defined in IFD0
#
# you can traverse each tag and work on it.
#
# exif.each do |tag|
#   p tag.to_s
# end
#
# # each tag in IFD0
# exif.each(:IFD0) do |ifd0_tag|
#  p ifd0_tag.to_s
# end
#
# 4. extract thumbnail
#
# File.open("thumb.jpg") do |dest|
#   exif.thumbnail dest
# end
#
# dest object must respond to '<<'.
#
require 'exifparser/scan'

module Exif

  class Parser
    #
    # create a new object. fpath is String.
    #
    def initialize(fpath)
      @fpath = fpath
      @scanner = nil
      File.open(fpath, "rb") do |f|
        @scanner = Exif::Scanner.new(f)
        @scanner.scan
      end
      @IFD0 = @scanner.result[:IFD0]
      @IFD1 = @scanner.result[:IFD1]
      @Exif = @scanner.result[:Exif]
      @GPS  = @scanner.result[:GPS]
      @Interoperability = @scanner.result[:Interoperability]
      @MakerNote = @scanner.result[:MakerNote]
      @thumbnail = @scanner.result[:Thumbnail]
    end

    def inspect
      sprintf("#<%s filename=\"%s\" entries: IFD0(%d) IFD1(%d) Exif(%d) GPS(%d) Interoperability(%d) MakerNote(%d)>", self.class, @fpath, @IFD0.length, @IFD1.length, @Exif.length, @GPS.length, @Interoperability.length, @MakerNote.length)
    end

    #
    # return true if specified tagid is defined or has some value.
    #
    def tag?(tagid)
      search_tag(tagid) ? true : false
    end

    #
    # search tag on the specific IFD
    #
    def tag(tagname, ifd=nil)
      search_tag(tagname, ifd)
    end

    #
    # search the specified tag values. return value is object of
    # classes defined under Exif::Tag module.
    #
    def [](tagname)
      self.tag(tagname)
    end

    #
    # set the specified tag to the specified value.
    # XXX NOT IMPLEMETED XXX
    #
    def []=(tag, value)
      # not implemented
    end

    #
    # extract the thumbnail image to dest. dest should respond to
    # '<<' method.
    #
    def thumbnail(dest)
      dest << @thumbnail
    end

    #
    # return the size of the thumbnail image
    #
    def thumbnail_size
      @thumbnail.size
    end

    #
    # return all the tags in the image.
    #
    # if argument ifd is specified, every tags defined in the
    # specified IFD are passed to block.
    #
    # return value is object of classes defined under Exif::Tag module.
    #
    # allowable arguments are:
    # * :IFD0
    # * :IFD1
    # * :Exif
    # * :GPS
    # * :Interoperability
    # * :MakerNote (if exist)
    def tags(ifd=nil)
      if ifd
        @scanner.result[ifd]
      else
        [
          @IFD0,
          @IFD1,
          @Exif,
          @GPS,
          @Interoperability,
          @MakerNote
        ].flatten
      end
    end

    #
    # execute given block with block argument being every tags defined
    # in all the IFDs contained in the image.
    #
    # if argument ifd is specified, every tags defined in the
    # specified IFD are passed to block.
    #
    # return value is object of classes defined under Exif::Tag module.
    #
    # allowable arguments are:
    # * :IFD0
    # * :IFD1
    # * :Exif
    # * :GPS
    # * :Interoperability
    # * :MakerNote
    def each(ifd=nil)
      if ifd
        @scanner.result[ifd].each{ |tag| yield tag }
      else
        [
          @IFD0,
          @IFD1,
          @Exif,
          @GPS,
          @Interoperability,
          @MakerNote
        ].flatten.each do |tag|
          yield tag
        end
      end
    end

    private

    def search_tag(tagID, ifd=nil)
      if ifd
        @scanner.result(ifd).find do |tag|
          case tagID
          when Fixnum
            tag.tagID.hex == tagID
          when String
            tag.name == tagID
          end
        end
      else
        [
          @IFD0,
          @IFD1,
          @Exif,
          @GPS,
          @Interoperability,
          @MakerNote
        ].flatten.find do |tag|
          case tagID
          when Fixnum
            tag.tagID.hex == tagID
          when String
            tag.name == tagID
          end
        end
      end
    end

  end # module Parser

end # module Exif

ExifParser = Exif::Parser
