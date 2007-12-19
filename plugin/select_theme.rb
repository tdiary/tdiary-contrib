# Copyright (C) 2005  akira yamada
# You can redistribute it and/or modify it under GPL2.

THEME_BASE = File.join(::TDiary::PATH, 'theme')
CACHE_FILE = File.join(@cache_path, 'theme_list')

def get_theme_list
  if FileTest.exist?(CACHE_FILE) &&
      File.mtime(CACHE_FILE) >= File.mtime(THEME_BASE)
    File.open(CACHE_FILE, 'r') do |i|
      i.flock(File::LOCK_EX)
      return Marshal.load(i.read)
    end
  end

  list = []
  Dir.glob(File.join(THEME_BASE, '*')).sort.each do |dir|
    theme = dir.sub(%r[.*/theme/], '')
    next unless FileTest::file?("#{dir}/#{theme}.css".untaint)
    name = theme.split(/_/).collect{|s| s.capitalize}.join(' ')
    list << [theme, name]
  end

  File.open(CACHE_FILE, 'w') do |o|
    o.flock(File::LOCK_EX)
    o.puts Marshal.dump(list)
  end

  return list
end

def select_theme_form
  options = ''
  get_theme_list.each do |theme, name|
    options << %Q!\t<option value="#{h theme}"#{' selected' if theme == @conf.theme}>#{h name}</option>\n!
    if theme == DEFAULT_THEME
      options = %Q!\t<option value="#{h theme}">(default)</option>\n! + options
    end
  end

  <<HTML
<form class="comment" method="get" action="#{h @index}">
 <select name="select_theme">
#{options}
 </select>
 <input type="submit" value="#{label}">
</form>
HTML
end

def label
  'use'
end

def check_theme(name)
  return false if name.nil? || name.empty?
  FileTest.file?(File.join(THEME_BASE, name, name + '.css'))
end

with_cgiparam = false
theme = nil
if @cgi.params['select_theme'] && @cgi.params['select_theme'][0]
  tmp = @cgi.params['select_theme'][0].gsub(/[^-.\w]/, '')
  tmp.untaint
  if check_theme(tmp)
    theme = tmp
    with_cgiparam = true
  end
end
if theme.nil? && @cgi.cookies && @cgi.cookies.include?('tdiary_select_theme')
  tmp = @cgi.cookies['tdiary_select_theme'][0].gsub(/[^-.\w]/, '')
  tmp.untaint
  theme = tmp if check_theme(tmp)
end
if theme.nil?
  theme = @conf.theme
end

cookie_path = File::dirname( @cgi.script_name )
cookie_path += '/' if cookie_path !~ /\/$/
cookie = CGI::Cookie::new(
    'name' => 'tdiary_select_theme',
    'value' => theme,
    'path' => cookie_path,
    'expires' => Time::now.gmtime + 90*24*60*60) # 90days
add_cookie(cookie)

# XXX: OK?
DEFAULT_THEME = @conf.theme
@conf.theme = theme
