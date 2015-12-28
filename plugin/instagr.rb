# -*- coding: utf-8 -*-
#
# instagr.rb - plugin to insert images on instagr.am
#              !! integrated into the instagram.rb.
#              !! Please use the instagram.rb
#
# Copyright (C) 2011-2015, tamoot <tamoot+tdiary@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#
# usage:
# <%= instagr 'short URL instag.ram' =>
# <%= instagr 'short URL instag.ram', size}  =>
#
# available size option:
#  :small  => 150x150 pixel
#  :medium => 306x306 pixel (default)
#  :large  => 612x612 pixel

def instagr( short_url, size = :medium)
   if respond_to?(:instagram)
      instagram( short_url, size )
   else
      return %Q|instagr.rb was integrated into instagram.rb. Please use the instagram.rb|
   end
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
