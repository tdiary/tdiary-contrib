# popit.rb:plugin embedding POP on POPit(http://pop-it.jp)
#
# usage:
#   popit(pop_id) - pop_id: The id of the POP on POPit (e.g. 2000 http://pop-it.jp/item/amazon/1989/pop/2000 )
#
# Copyright (c) KAYA Satoshi <http://kayakaya.net/>
# You can redistributed it and/or modify if under GPL2.
#
def popit(pop_id, size = "large")
  return unless pop_id

  width_size = {"large" => "260", "small" => "180" }
  height_size = {"large" => "380", "small" => "220" }
  width_style = {"large" => "220px", "small" => "160px" }

  sizequery = size == "large" ? "?size=large" : ''
  r = ""
  r << %Q|<iframe src="http://pop-it.jp/pop/blogparts/#{pop_id}#{sizequery}" frameborder="0" width="#{width_size[size]}" height="#{height_size[size]}"> </iframe>|
  r << %Q|<div style="width:#{width_style[size]};margin:0;text-align:center;font-size:12px;">Powered by <a href="http://pop-it.jp" target="_blank" style="color: #edbe26;">POPit</a></div>|

  return r
end
