# Copyright (C) 2009 Hideki Sakamoto <hs@on-sky.net>
require 'hikidoc'

def inline_wiki(buf)
  HikiDoc::to_html(buf)
end
