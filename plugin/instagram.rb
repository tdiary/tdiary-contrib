# instagram.rb - embed your photo/videos in instagram to a diary
#
# Author: Tatsuya Sato
# License: GPL

def instagram(code, width=612, height=700)
  <<-BODY
<iframe src="//instagram.com/p/#{code}/embed/" width="#{width}" height="#{height}" frameborder="0" scrolling="no" allowtransparency="true"></iframe>
  BODY
end
