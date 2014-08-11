# Twitter Summary Card plugin
#
#
# Copyright (c) 2013 Tatsuya Sato <satoryu.1981@gmail.com>

def twitter_summary_card_description
  section_index = @cgi.params['p'][0]
  if @mode == 'day' and section_index
    diary = @diaries[@date.strftime('%Y%m%d')]
    sections = diary.instance_variable_get(:@sections)
    section = sections[section_index.to_i - 1].body_to_html
    @conf.shorten(apply_plugin(section, true), 200)
  else
    @conf.description
  end
end

add_header_proc do
  headers = {
    'twitter:card' => 'summary',
    'twitter:site' => @conf['twitter_summary_card.site'] || @conf['twitter_summary_card.creator'],
    'twitter:creator' => @conf['twitter_summary_card.creator'],
    'twitter:title' => title_tag.match(/>([^<]+)/).to_a[1],
    'twitter:description' => twitter_summary_card_description,
    'twitter:image:src' => @conf.banner
  }
  headers = headers.select { |_, v| v && not(v.empty?) }
  headers = headers.map do |k, v|
    %Q|<meta name="#{k}" content="#{CGI.escapeHTML(v)}">|
  end

  headers.join("\n")
end

add_conf_proc('Twitter Summary Card', 'Twitter Summary Card') do
  if @mode == 'saveconf'
    @conf['twitter_summary_card.site'] = @cgi.params['twitter_summary_card.site'][0]
    @conf['twitter_summary_card.creator'] = @cgi.params['twitter_summary_card.creator'][0]
  end

  <<-HTML
  <h2>Twitter Summary Card</h2>
  <p>
  Please refer to the following documentation at first.
  <ul>
    <li><a href="https://dev.twitter.com/docs/cards/types/summary-card" target="_blank">Summary Card | Twitter Developers</a></li>
  </ul>
  </p>

	<h3>Your tDiary's Twitte account</h3>
	<p><input name="twitter_summary_card.site" value="#{h(@conf['twitter_summary_card.site'])}"></p>

	<h3>Creator's Twitter account </h3>
	<p><input name="twitter_summary_card.creator" value="#{h(@conf['twitter_summary_card.creator'])}"></p>
  HTML
end
