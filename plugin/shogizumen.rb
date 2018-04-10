# -*- coding: utf-8 -*-
#
# shogizumen.rb -- Just enable shogizumen.min
#
# Copyright (c) KITADAI, Yukinori <https://nyoho.jp/>
# MIT License
#
# shogizumen.min.js is under MIT license.

enable_js('shogizumen.min.js')

def shogizumen(zumen_string)
  '<pre class="shogizumen">' + zumen_string + '</pre>'
end
