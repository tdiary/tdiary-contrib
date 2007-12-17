#
# hb_footer.rb
#
# はてなブックマーク (http://b.hatena.ne.jp/) のコメントを該当セクションに貼り付けるtDiaryプラグイン
# 改造版rss_recent Version 0.0.5i2と共に使用する
#
# Licence: GPL
# Author: ishinao <ishinao@ishinao.net>
#

add_section_leave_proc do |date, index|
  td_url = "http://tdiary.ishinao.net/#{date.strftime('%Y%m%d')}.html%23p#{'%02d' % index}"
  hb_url = "http://b.hatena.ne.jp/entry/#{td_url}"
  rss_url = "http://b.hatena.ne.jp/entry/rss/#{td_url}"

  template_head = %Q[<div class="section">\n<h4>このセクションに対する<a href="#{CGI.escapeHTML(hb_url)}">はてブ</a></h4>\n<ul class="hb_footer">\n]
  template_list = '<li><span class="date">#{time.strftime("%Y年%m月%d日")}</span> <span class="hatenaid"><a href="#{CGI.escapeHTML(url)}">#{CGI.escapeHTML(title)}</a></span> <span class="comment">#{CGI.escapeHTML(description.to_s)}</span></li>'
  template_foot = "</ul>\n</div>\n"

  cache_time = 3600;
  if date.strftime('%Y-%m-%d') != Time.now.strftime('%Y-%m-%d')
    cache_time = 3600 * 12;
  end
  rss_recent(rss_url, 50, cache_time, template_head, template_list, template_foot)
end

