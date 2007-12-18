=begin
delicious.rb
del.icio.us から その日付分のメモを取ってきて表示するプラグイン

tdiary.conf で以下を設定します。tDiaryの設定画面からも設定可能です。

  @options['delicious.id'] = 'YOUR DELICIOUS ID HERE'
  @options['delicious.pw'] = 'YOUR DELICIOUS PW HERE'

proxy は以下に設定します。

  @options['amazon.proxy'] = 'PROXY_HOST:PORT'

reference:
* mm_footer.rb by ishinao san
* rss-show.rb (in Hiki) by TAKEUCHI Hitoshi san
* fujisan.rb by Michitaka Ohno.

=end

require 'net/https'
require 'rexml/document'
require 'fileutils'

def force_to_euc(str)
  begin
	 str2 = Uconv.u8toeuc(str)
  rescue Uconv::Error
	 str2 = NKF::nkf("-e", str)
  end
  return str2
end

def delicious_save_cache cache_file, file
  FileUtils.mkdir_p "#{@cache_path}/delicious"
  File.open("#{@cache_path}/delicious/#{cache_file}", 'w') do |f|
	 f.flock(File::LOCK_EX)
	 f.puts file
	 f.flock(File::LOCK_UN)
  end
end

def delicious_parse_xml(xml)
  posts = []
  REXML::Document.new(xml).elements.each("posts/post") do |post|
	 post = <<-EOS
<li><a href="#{post.attribute("href").to_s}">
#{force_to_euc(post.attribute("description").to_s)}
</a></li>
	 EOS
	 posts << post.gsub(/[\n\r]/,'')
  end

  return posts
end

def delicious_get_html(date = Date.now)
  req = Net::HTTP::Get.new "/v1/posts/get?dt=#{date.strftime('%Y-%m-%d')}"
  req.basic_auth @options['delicious.id'], @options['delicious.pw']

  https = Net::HTTP.new('api.del.icio.us', 443)
  https.use_ssl = true

  parsed = https.start {|w|
	 response = w.request(req)
	 delicious_parse_xml(response.body)
  }

  delicious_save_cache date.strftime("%Y-%m-%d"), parsed
end


add_edit_proc do |date|
  delicious_get_html date
  nil
end

add_body_leave_proc do |date|
  path = "#{@cache_path}/delicious/#{date.strftime('%Y-%m-%d')}"
  ret = ''

  if File.exist? path
	 File.open(path) do |file|
		ret = <<-EOS
	 <h3>del.icio.us</h3>
	 <ul>
		#{file.read}
	 </ul>
	 EOS
	 end
  end
  ret
end


def delicious_init
	@conf['delicious.id'] ||= ""
	@conf['delicious.pw'] ||= ""
	@conf['delicious.title'] ||= "Todey's URL Clip"
end

add_conf_proc( 'delicious', @delicious_label_conf ) do
	delicious_conf_proc
end

def delicious_conf_proc
  if @mode == 'saveconf' then
	 @conf['delicious.id'] = @cgi.params['delicious.id'][0]
	 @conf['delicious.pw'] = @cgi.params['delicious.pw'][0]
  end

  delicious_init

  <<-HTML
	<h3>#{@delicious_label_id}</h3>
	<p><input name="delicious.id" value="#{CGI::escapeHTML( @conf['delicious.id'] )}"></p>
	<h3>#{@delicious_label_pw}</h3>
	<p><input name="delicious.pw" value="#{CGI::escapeHTML( @conf['delicious.pw'] )}"></p>
	HTML
end