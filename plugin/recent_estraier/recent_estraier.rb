# recent_estraier.rb $Revision 1.1 $
#
# recent_estraier: Estraier検索語新しい順
# 		 estsearch.cgiが作成する検索キーワードログから
#		 最新xx件分の検索語を表示します。
# パラメタ:
#   file:       検索キーワードログファイル名(絶対パス表記) 
#   estraier:     estseach.cgiのパス 
#   limit:      表示件数(未指定時:5) 
#   make_link:  <a>を生成するか?(未指定時:生成する)    
#
#
# Copyright (c) 2005 SHIBATA Hiroshi <h-sbt@nifty.com>
# Distributed under the GPL2.
#

require 'nkf'

def recent_estraier(file, estraier, limit = 5, make_link = true)
   begin
      lines = []
      log = open(file)
      if log.stat.size > 300 * limit then
         log.seek(-300 * limit,IO::SEEK_END)
      end
      log.each_line do |line|
         lines << line
      end
      
      result = "<ol>"
      lines.reverse.each_with_index do |line,idx|
         break if idx >= limit
         word = NKF::nkf('-We -m0', line.split(/\t/)[2])
         if word.empty? then
            limit += 1
         else
            if make_link
               result << %Q|<li><a href="#{estraier}?phrase=#{u(h(word))}&enc=EUC-JP">#{h word}</a></li>|
            else
               result << %Q|#{h word}|
            end
         end
      end
		
      result << %Q[</ol>]
      
   rescue
		%Q[<p class="message">#$! (#{$!.class})<br>cannot read #{file}.</p>]
	end
end
