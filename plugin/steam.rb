# -*- coding: utf-8 -*-
# steam.rb $Revision: 1.0 $
#
# 概要:
# steam(store.steampowered.com)のゲームのウィジェットを
# 貼るプラグインです。
#
# 使い方:
# steamの任意のゲームのID(store.steampowered.com/app/{id})
# を指定することにより、ウィジェットが貼り付けられます。
#
# Copyright (c) 2016 kp <kp@mmho.net>
# Distributed under the GPL
#

=begin ChangeLog
=end

def steam( id )
   %Q[<iframe src="//store.steampowered.com/widget/#{id}/" frameborder="0" width="646" height="190" style="max-width:100%;"></iframe>]
end
