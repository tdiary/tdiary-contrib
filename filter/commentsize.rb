#
# comment_size.rb: included TDiary::Filter::CommentSizeFilter class
#

module TDiary
   module Filter
      class CommentsizeFilter < Filter
         def comment_filter( diary, comment )
            return false if comment.body.size > @conf['comment.size']
            true
         end

         def referer_filter( referer )
            true
         end
      end
   end
end
