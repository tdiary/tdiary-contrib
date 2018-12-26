# Twitter Summary Card plugin
#
#
# Copyright (c) 2013 Tatsuya Sato <satoryu.1981@gmail.com>

def twitter_summary_card_description
  section_index = @cgi.params['p'][0]
  if @mode == 'day'
    diary = @diaries[@date.strftime('%Y%m%d')]
    sections = diary.instance_variable_get(:@sections)
    section = nil
    if section_index
      section = sections[section_index.to_i - 1].body_to_html
    else
      section = sections.first.body_to_html
    end
    @conf.shorten(apply_plugin(section, true), 200)
  else
    @conf.description
  end
end

add_header_proc do
  card_type = 'summary'
  image_src = @conf.banner
  if @mode == 'day' && @conf['twitter_summary_card.use_attached_image']
    images = image_list(@date.strftime('%Y%m%d'))
    unless images.empty?
      card_type = 'summary_large_image'
      image_src = "#{@image_url}/#{images.first}"
    end
  end
  headers = {
    'twitter:card' => card_type,
    'twitter:site' => @conf['twitter_summary_card.site'] || @conf['twitter_summary_card.creator'],
    'twitter:creator' => @conf['twitter_summary_card.creator'],
    'twitter:title' => title_tag.match(/>([^<]+)/).to_a[1],
    'twitter:description' => twitter_summary_card_description,
    'twitter:image:src' => image_src
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
    @conf['twitter_summary_card.use_attached_image'] = @cgi.params['twitter_summary_card.use_attached_image'][0] == "on"
  end

  <<-HTML
  <h2>Twitter Summary Card</h2>
  <p>
  Please refer to the following documentation at first.
  <ul>
    <li><a href="https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/abouts-cards" target="_blank">About Twitter Cards — Twitter Developers</a></li>
  </ul>
  </p>

	<h3>Your tDiary's Twitte account</h3>
	<p><input name="twitter_summary_card.site" value="#{h(@conf['twitter_summary_card.site'])}"></p>

	<h3>Creator's Twitter account </h3>
	<p><input name="twitter_summary_card.creator" value="#{h(@conf['twitter_summary_card.creator'])}"></p>

	<p><label><input name="twitter_summary_card.use_attached_image" type="checkbox" value="on" #{@conf['twitter_summary_card.use_attached_image'] && "checked"}>Use attached image</label></p>
  HTML
end
