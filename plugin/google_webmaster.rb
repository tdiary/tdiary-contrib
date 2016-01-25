# encoding: utf-8
# google-webmaster.rb - embed a meta tag to let Google Webmaster tool know your verification code.
#
# Copyright (C) 2012, Tatsuya Sato <satoryu.1981@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#

add_header_proc do
  "<meta name=\"google-site-verification\" content=\"#{h @conf['google_webmaster.verification']}\" />"
end

add_conf_proc('Google Webmaster', 'Google ウェブマスターツール', 'etc') do
  if @mode == 'saveconf'
    @conf['google_webmaster.verification'] = @cgi.params['google_webmaster.verification'][0]
  end
  <<-HTML
  <h3>Google ウェブマスターツールの検証コード</h3>
  <p>
  <input name='google_webmaster.verification' value="#{h @conf['google_webmaster.verification']}" />
  </p>
  HTML
end
