#
# ref. http://www.cozmixng.org/retro/projects/tdiary/ticket/60
#

module TDiary::Filter
   class HidecommentFilter < Filter
      def comment_filter( diary, comment )
         comment.show = false # ツッコミを非表示にするが
         true # spam扱いにはしない
      end
   end
end

