#!/usr/bin/env ruby
#
#  mk_nikonflensname.rb
#
#  .. makes the Ruby source code of hash table: Nikon EXIF LensParameters => Lens model name.
#  This is for Exif::Makernote::Tag::LensParameters class
#  in exifparser/nmakernote/nikon2.rb
# 
# usage : ruby mk_nikonlens_hash.rb nikonmn.cpp >nikonflensname.rb
# ("nikonmn.cpp" is a exiv2(http://www.exiv2.org/)'s nikon makernote module source code. )
#
# Copyright (c) 2009 N.KASHIJUKU <n-kashi[at]whi.m-net.ne.jp>
# You can redistribute it and/or modify it under GPL2.
#
print <<TEOS
module Exif
  module Tag
    module NikonFmount
      LensName = {
TEOS

open(ARGV[0], "r") do |file|
  file.each_line do |s|
    if (/^\{(0x..),(0x..),(0x..),(0x..),(0x..),(0x..),(0x..),0x..,0x..,0x..,0x.., \"(.*)\", ".*", "(.*)"\}/ =~ s) != nil
      str = %Q[        \[#{$1}, #{$2}, #{$3}, #{$4}, #{$5}, #{$6}, #{$7}\] => "#{$8} #{$9}"]
      str.sub!("f/", "F") if str.include?("Nikon")
      print str + ",\n"
    end
  end
end

print <<EEOS
        [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] => ""
      }
    end
  end
end
EEOS

