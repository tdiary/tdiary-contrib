# cocomment.rb $Revision: 1.6 $
#
# Copyright (C) 2006 by Hiroshi SHIBATA
# You can redistribute it and/or modify it under GPL2.
#

if @mode == 'day' and not bot? and not @conf.mobile_agent? then
   add_body_enter_proc do |date|
		<<-SCRIPT
      <script type="text/javascript">
      coco =
      {
          blogTool               : "tDiary",
          blogURL                : "#{h @conf.base_url}",
          blogTitle              : "#{h @conf.html_title}",
          postURL                : "#{h @conf.base_url + anchor( date.strftime( '%Y%m%d' ) )}",
          postTitle              : "#{h apply_plugin( @diaries[date.strftime('%Y%m%d')].title, true )}",
          commentAuthorFieldName : "name",
          commentAuthorLoggedIn  : false,
          commentFormName        : "comment-form",
          commentTextFieldName   : "body",
          commentButtonName      : "comment"
      }
      </script>
      <script id="cocomment-fetchlet" src="http://www.cocomment.com/js/enabler.js" type="text/javascript">
      </script>
		SCRIPT
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vi: ts=3 sw=3
