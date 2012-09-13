# wikiext_style.rb: when using wiki style, extends behavior.
#
# Just place this file into tdiary/style directory.
#
# Copyright (C) 2012, kdmsnr <kdmsnr@gmail.com>
# You can distribute this under GPL.
#

module TDiary
  class WikiextDiary # dummy class
  end
end

require "hikidoc"
class HikiDoc
  class HTMLOutput
    def paragraph(lines)
      @f.puts "<p>#{lines.join("")}</p>"
    end
  end
end
