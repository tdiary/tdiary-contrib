#!/usr/bin/env ruby -Ke
# Copyright(c) 2004 URABE, Shyouhei.
#
# Permission is hereby granted, free of  charge, to any person obtaining a copy
# of  this code, to  deal in  the code  without restriction,  including without
# limitation  the rights  to  use, copy,  modify,  merge, publish,  distribute,
# sublicense, and/or sell copies of the code, and to permit persons to whom the
# code is furnished to do so, subject to the following conditions:
#
#        The above copyright notice and this permission notice shall be
#        included in all copies or substantial portions of the code.
#
# THE  CODE IS  PROVIDED "AS  IS",  WITHOUT WARRANTY  OF ANY  KIND, EXPRESS  OR
# IMPLIED,  INCLUDING BUT  NOT LIMITED  TO THE  WARRANTIES  OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE  AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHOR  OR  COPYRIGHT  HOLDER BE  LIABLE  FOR  ANY  CLAIM, DAMAGES  OR  OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF  OR IN CONNECTION WITH  THE CODE OR THE  USE OR OTHER  DEALINGS IN THE
# CODE.

# $Id: hatena_style.rb,v 1.12 2007-02-27 06:57:14 kazuhiko Exp $
# Hatena::Diary compatible style
# Works only under ruby 1.8.1 or later

[
  'uri',
  'net/http',
  'cgi',
  'pstore',
  'time',
].each {|f| require f }

class TDiary::HatenaDiary
  include TDiary::DiaryBase, TDiary::CategorizableDiary

  def initialize(date, title, body, modified=Time.now)
    init_diary
    @sections = []
    replace date, title, body
    @last_modified = modified
  end

  def style
    'Hatena'
  end

  def replace(date, title, body)
    set_date date
    set_title title
    @sections.clear
    append body
  end

  def append(body, author=nil)
    @sections.concat Hatena::Diary.parse(body, author)
    self
  end

  def each_section(&block)
    @sections.each(&block)
  end

  def to_src
    @sections.inject('') {|r, i| r << i.to_src }
  end

  def to_html(opt, mode=:HTML)
    j = 0
    @sections.inject('') {|r, i|
      j += 1
      r << '<div class="section">' if mode != :CHTML
      r << i.convert(mode, date, j, opt)
      r << '</div>' if mode != :CHTML
      r
    }
  end

  def to_s
    sprintf('date=%s, title=%s, body=%s',
            date.strftime('%Y%m%d'),
            title,
            @sections.map {|i| '[%s]' % i}.join)
  end
end

# This is the namespace module
module Hatena

  def Hatena.conf
    ObjectSpace.each_object do |diary|
      next unless diary.kind_of?(TDiary::TDiaryBase)
      return diary.instance_eval { @conf }
    end
  end

  Diary = Object.new
  API = Object.new

  # get a text of hatena-style, and convert it into parse tree.
  def Diary.parse(str, author)
    str.gsub(/\r(?=\n)/,'')\
       .gsub(/\r/,"\n")\
       .gsub(/^\*/,'**')\
       .split(/^\*/)\
       .inject([]) {|r, i| i.empty? ? r : r << Hatena::Section.new(i, author) }
  end

  # find the cache_path from entore ruby world
  # could someone please tell me more eficient way to do this...
  def API.cache_path
    ret = Hatena.conf.cache_path || Hatena.conf.data_path + '/cache'

    unless FileTest.directory?(ret)
      begin
        Dir.mkdir(ret)
      rescue Errno::EEXIST
        ;                       # OK
      end
    end
    ret
  end

  def API.update_kw(kw)
    return false if File.exist?(kw) && Time.now - File.mtime(kw) < 86400
    File.open(kw, IO::WRONLY|IO::CREAT) do |fp|
      break unless fp.flock(IO::LOCK_EX|IO::LOCK_NB)
      uri = ::URI.parse('http://d.hatena.ne.jp/images/keyword/keywordlist')
      timeout(60) do
        Net::HTTP.version_1_1
        Net::HTTP.new(uri.host, uri.port).start do |http|
          res, body = http.get(uri.request_uri,
                               {'User-Agent' => "tDiary/#{TDIARY_VERSION}"})
          fp.seek(0, IO::SEEK_SET)
          fp.write(body)
        end
      end
    end
    true
  end

  def API.update_db(kw, db)
    raise if API.update_kw kw
    raise unless FileTest.exist? db.path
    false
  rescue
    str = File.open(kw, IO::RDONLY) do |fp|
      fp.flock(IO::LOCK_SH)
      fp.read
    end
    a = str.gsub(/\\s/,' ')                       \
           .gsub(/\\([^\|])/,'\1')                \
           .scan(/(?:[^\|]|\\\|)*[^\\](?=\||\z)/)
    db.transaction do
      db['trie'] = Trie.new(a)
    end
    true
  end

  # The trie of keywords
  # Keywords are chached, chache expires every day (24h)
  def API.keywords
    path = API.cache_path
    kw = path + '/keywordlist'
    db = PStore.new(path + '/keywords.pstore')
    if API.update_db(kw, db) || @ret.nil?
      db.transaction(IO::RDONLY) do
        @ret = db['trie']
      end
    end
    return @ret
  end
end

# Deterministic finate automata
class Hatena::Trie

  private
  def add(kw)
    h = @hash1
    kw.split(//e).each do |c|
      unless h.has_key? c
        tmp = Hash.new
        @ary << tmp
        h[c] = tmp
      end
      h = h[c]
    end
    @hash2[h] = kw
  end

  def initialize(a)
    @ary = Array.new
    @hash1 = Hash.new
    @hash2 = Hash.new
    a.each {|kw| add kw }
  end

  public
  def match(str)
    ret = nil
    h = @hash1
    a = str.split(//e)
    i = 0
    j = 0
    while c = a[i + j]
      if h[c]
        h = h[c]
        if @hash2[h]
          ret = @hash2[h]
        end
        f = false
        j += 1
      else
        return ret if ret
        h = @hash1 # reset
        i += 1
        j = 0
      end
    end
    return ret
  end
end

# --------
# Parser Tree Nodes

class Hatena::Section
  def initialize(str, author)
    t = Time.now
    @author = author.freeze
    @src    =  str.gsub(/^\*t\*/, '*%d*' % t.to_i)\
               .gsub(/<(ins|del)>/, '<\1 datetime="%s">' % t.xmlschema)
    @tree   = Hatena::Block.new(@src)
  end

  def convert(mode, date, i, opt)
    @tree.convert(mode, date, i, opt, author)
  end

  def to_src
    @src
  end

  def categories
    @tree.title.categories
  end

  def author
    @author
  end

  def body
    @tree.body.to_s
  end

  def subtitle
    @tree.title.to_s
  end

  def stripped_subtitle
    @tree.title.strip.to_s
  end

  def body_to_html
    @tree.body.convert(:HTML)
  end

  def subtitle_to_html
    @tree.title.convert(:HTML)
  end

  def stripped_subtitle_to_html
    @tree.title.strip.convert(:HTML)
  end
end

# Block level elements
class Hatena::Block
  attr_reader :to_s, :title, :body

  def initialize(str) # Too long.  Needs refactoring.
    if str.nil?
      @title = Hatena::Title.new('')  # dummy
      @body  = Hatena::Inline.new('') # dummy
      @to_s  = ''
    elsif str[0] == ?*
      t,b = *str.split(/\n/,2)
      @title = Hatena::Title.new(t)
      @body  = Hatena::Block.new(b)
      @to_s  = t + "\n" + (b||'')
    else
      @to_s  = str
      @title = Hatena::Title.new('') # dummy
      @body  = self
      @elems = Array.new
      lines  = str.concat("\n").scan(/.*\n/)
      until lines.empty?
        case
        when lines[0][0] == ?-
          buffer = ''
          until lines.empty?
            break unless lines[0][0] == ?-
            buffer.concat lines.shift
          end
          @elems.push Hatena::Itemize.new(buffer)
        when lines[0][0] == ?+
          buffer = ''
          until lines.empty?
            break unless lines[0][0] == ?+
            buffer.concat lines.shift
          end
          @elems.push Hatena::Enumerate.new(buffer)
        when lines[0][0] == ?:
          buffer = ''
          until lines.empty?
            break unless lines[0][0] == ?:
            break unless lines[0].rindex(?:) != 0
            buffer.concat lines.shift
          end
          @elems.push Hatena::Description.new(buffer)
        when lines[0] == ">>\n"
          buffer = ''
          nest = 0
          until lines.empty?
            nest += 1 if lines[0] == ">>\n"
            nest -= 1 if lines[0] == "<<\n"
            buffer.concat lines.shift
            break if nest <= 0
          end
          @elems.push Hatena::Quote.new(buffer)
        when lines[0] == ">|\n"
          buffer = ''
          until lines.empty?
            str1 = lines.shift
            buffer.concat str1
            break if /\|<$/ =~ str1
          end
          @elems.push Hatena::Verbatim.new(buffer)
        when lines[0] == ">||\n"
          buffer = ''
          until lines.empty?
            str1 = lines.shift
            buffer.concat str1
            break if /\|\|<$/ =~ str1
          end
          @elems.push Hatena::SuperVerbatim.new(buffer)
        when lines[0][0,5] == '><!--'
          # comment, throwing away
          until lines.empty?
            break if /--><$/ =~ lines.shift
          end
        when lines[0][0,2] == '><'
          buffer = ''
          until lines.empty?
            str1 = lines.shift
            buffer.concat str1
            break if /><$/ =~ str1
          end
          @elems.push Hatena::UnParagraph.new(buffer)
        else
          buffer = ''
          until lines.empty?
            break if /\A(\-|\+|\:|\>[\<\>\|])/ =~ lines[0]
            buffer.concat lines.shift
            break if buffer[-3..-1] == "\n\n\n"
          end
          @elems.push Hatena::Paragraph.new(buffer)
        end
      end
    end
  end

  def convert(mode, date=nil, i=nil, opt=nil, author=nil)
    if @body == self
      @elems.inject('') {|r, i| r << i.convert(mode) + "\n" }
    else
      @title.convert(mode, date, i, opt, author) + "\n" + @body.convert(mode)
    end
  end
end

# Section subtitle
class Hatena::Title
  attr_reader :to_s, :categories, :strip

  def initialize(str)
    if m = /\A\*(\d+)\*/.match(str)
      @time     = Time.at(Integer(m[1]))
      @to_s     = m.post_match.freeze
    elsif m = /\A\*(\w+)\*/.match(str)
      @name     = m[1]
      @to_s     = m.post_match.freeze
    else
      @to_s     = (str[1..-1]||'').freeze
    end
    @categories = to_s.scan(/\[(.*?)\]/).map{|a| a[0] }
    @strip      = Hatena::Inline.new(Regexp.last_match ? Regexp.last_match.post_match : to_s)
  end

  def convert(mode, date=nil, i=nil, opt=nil, author=nil)
    id = ('p%02d' % (i || 0))
    h = '%0.32b' % rand(0x100000000)
    case
    when date.nil?
      categories.map {|i|
        "<%=category_anchor <<'#{h}'.chomp\n#{i}\n#{h}\n%>"
      }.join + strip.convert(mode)
    when mode == :CHTML
      sprintf('<H3%s><A NAME="%s">*</A>%s%s</H3>',
              @name ? %Q{ ID"=#@name"} : '',
              id,
              (opt['multi_user'] && author) ? "[#{author}]" : '',
              strip.convert(mode))
    else
      sprintf('<h3%s><a %shref="%s<%%=anchor "%s"%%>#%s">%s</a>%s%s%s %s</h3>',
              @name ? %Q{ id="#@name"} : '',
              opt['anchor'] ? 'name="%s" ' % id : '',
              opt['index'],
              date.strftime('%Y%m%d'),
              @name || id,
              opt['section_anchor'],
              categories.map {|cat|
                "<%=category_anchor <<'#{h}'.chomp\n#{cat}\n#{h}\n%>"
              }.join,
              (opt['multi_user'] && author) ? "[#{author}]" : '',
              strip.convert(mode),
              @time ? %Q!<span class="timestamp">#{@time.strftime('%H:%M')}</span>! : '')
    end
  end
end

# Itemize
# extension to Hatena: nest can be more than 3 level.
class Hatena::Itemize
  def initialize(str)
    @elems = Array.new
    lines  = str.gsub(/^\-/,'').scan(/.*\n/)
    buffer = ''
    until lines.empty?
      case
      when lines[0][0] == ?-
        until lines.empty?
          break unless lines[0][0] == ?-
          buffer.concat lines.shift
        end
        @elems.push Hatena::Block.new(buffer)
        buffer = ''
      when lines[0][0] == ?+
        until lines.empty?
          break unless lines[0][0] == ?+
          buffer.concat lines.shift
        end
        @elems.push Hatena::Block.new(buffer)
        buffer = ''
      when lines[0][0] == ?:
        until lines.empty?
          break unless lines[0][0] == ?:
          break unless lines[0].rindex(?:) != 0
          buffer.concat lines.shift
        end
        @elems.push Hatena::Blcok.new(buffer)
        buffer = ''
      else
        @elems.push Hatena::Inline.new(buffer) unless buffer.empty?
        buffer = lines.shift
      end
    end
    @elems.push Hatena::Inline.new(buffer) unless buffer.empty?
  end

  def convert(mode)
    template = nil
    if mode == :CHTML
      template = ["<UL>%s\n</UL>", "\n<LI>%s</LI>"]
    else
      template = ["<ul>%s\n</ul>", "\n<li>%s</li>"]
    end
    template[0] % @elems.inject('') {|r, i|
      r << template[1] % i.convert(mode)
    }
  end
end


# Enumerate
# Extension to Hatena: nest can be more than 3 level
class Hatena::Enumerate
  def initialize(str)
    @elems = Array.new
    lines  = str.gsub(/^\+/,'').scan(/.*\n/)
    buffer = ''
    until lines.empty?
      case
      when lines[0][0] == ?-
        until lines.empty?
          break unless lines[0][0] == ?-
          buffer.concat lines.shift
        end
        @elems.push Hatena::Block.new(buffer)
        buffer = ''
      when lines[0][0] == ?+
        until lines.empty?
          break unless lines[0][0] == ?+
          buffer.concat lines.shift
        end
        @elems.push Hatena::Block.new(buffer)
        buffer = ''
      when lines[0][0] == ?:
        until lines.empty?
          break unless lines[0][0] == ?:
          break unless lines[0].rindex(?:) != 0
          buffer.concat lines.shift
        end
        @elems.push Hatena::Blcok.new(buffer)
        buffer = ''
      else
        @elems.push Hatena::Inline.new(buffer) unless buffer.empty?
        buffer = lines.shift
      end
    end
    @elems.push Hatena::Inline.new(buffer) unless buffer.empty?
  end

  def convert(mode)
    template = nil
    if mode == :CHTML
      template = ["<OL>%s\n</OL>", "\n<LI>%s</LI>"]
    else
      template = ["<ol>%s\n</ol>", "\n<li>%s</li>"]
    end
    template[0] % @elems.inject('') {|r, i|
      r << template[1] % i.convert(mode)
    }
  end
end

# Description list
# Extension to hatena : term only and descriotion only are OK
#   :term:
#   ::desc
# Extension to Hatena : can be combined with lists
class Hatena::Description
  def initialize(str)
    @elems = Array.new
    str.each_line do |l|
      raise SyntaxError unless l[0] == ?:
      l = l[1..-1]
      buffer = ''
#       while l =~ /[^:]*#{URI.regexp}/o
#         buffer.concat Regexp.last_match.to_s
#         l = Regexp.last_match.post_match
#       end
      dt,dd = *l.split(/:/,2)
      buffer.concat dt
      @elems.push([
        buffer.empty? ? nil : Hatena::Inline.new(buffer),
        (dd.nil? || dd.empty?) ? nil : Hatena::Inline.new(dd)
      ])
    end
  end

  def convert(mode)
    template = nil
    if mode == :CHTML
      template = ["<DL>%s\n</DL>", "\n<DT>%s</DT>", "<DD>%s</DD>"]
    else
      template = ["<dl>%s\n</dl>", "\n<dt>%s</dt>", "<dd>%s</dd>"]
    end
    template[0] % @elems.inject('') {|r, i|
      r << template[1] % i[0].convert(mode) unless i[0].nil?
      r << template[2] % i[1].convert(mode) unless i[1].nil?
      r
    }
  end
end

# block level quote
# Extension to hatena : nest can be more than 2 level.
class Hatena::Quote
  def initialize(str)
    @elems = Hatena::Block.new(str[3..-4])
  end

  def convert(mode)
    template = nil
    if mode == :CHTML
      template = "<BLOCKQUOTE>\n%s\n</BLOCKQUOTE>"
    else
      template = "<blockquote>\n%s\n</blockquote>"
    end
    sprintf(template,@elems.convert(mode))
  end
end

# preformatted text
class Hatena::Verbatim
  def initialize(str)
    @str = str[3..-4].freeze
  end

  def convert(mode)
    template = nil
    if mode == :CHTML
      template = "<PRE>%s</PRE>"
    else
      template = "<pre>%s</pre>"
    end
    sprintf(template,CGI.escapeHTML(@str))
  end
end

# preformatted text
class Hatena::SuperVerbatim
  def initialize(str)
    @str = str[3..-5].freeze
  end

  def convert(mode)
    template = nil
    if mode == :CHTML
      template = "<PRE>%s</PRE>"
    else
      template = "<pre>%s</pre>"
    end
    sprintf(template,CGI.escapeHTML(@str))
  end
end

# non-paragraph blocklevel
class Hatena::UnParagraph
  def initialize(str)
    @elems = Hatena::Inline.new(str[1..-3])
    # 0123...
    # ><div>
    # ... ...
    # ... </div><\n
    #      ...-321
  end

  def convert(mode)
    @elems.convert(mode)
  end
end

# paragraph
# Extension to Hatena: not using <br> but begins next paragraph
class Hatena::Paragraph
  def initialize(str)
    @elems = Hatena::Inline.new(str.gsub(/\n\n\n/,''))
  end

  def convert(mode)
    template = nil
    if mode == :CHTML
      template = "<P>\n%s\n</P>"
    else
      template = "<p>\n%s\n</p>"
    end
    sprintf(template, @elems.convert(mode))
  end
end

# inline elements
class Hatena::Inline
  def initialize(str)
    @elems = Array.new
    inside_a = false
    return if str == "\n"
    until str.empty?
      case str
      when /\A\[\](.*?)\[\]/m
        @elems.push Hatena::CDATA.new(Regexp.last_match[1])
      when /\A\)\(\((.*?)\)\)\(/m, /\A\(\(\((.*?)\)\)\)/m
        @elems.push Hatena::CDATA.new('((')
        @elems.push Hatena::Inline.new(Regexp.last_match[1])
        @elems.push Hatena::CDATA.new('))')
      when /\A\(\((.*?)\)\)/m
        @elems.push Hatena::Footnote.new(Regexp.last_match[1])
      when /\A#{tag_regex}/o
        @elems.push Hatena::TAG.new(Regexp.last_match.to_s)
        if str.index("<a") == 0
          inside_a = true
        elsif str.index("</a>") == 0
          inside_a = false
        end
      when /\A\[amazon:(.*?)\]/m
        @elems.push Hatena::AmazonSearch.new(Regexp.last_match[1], true)
      when /\A\[google:(.*?)\]/m
        @elems.push Hatena::Google.new(Regexp.last_match[1], true)
      when /\A\[(?:(g:(?:.*?)):)?keyword:(.*?)\]/m, /\A\[\[(.*?)\]\]/m
        m = Regexp.last_match
        @elems.push Hatena::Keyword.new(m[1], m[2], true)
      when /\A\[(?:(g:(?:.*?)|a|d):)?id:(.*?)\]/m, /\A(?:(g:(?:.*?)|a|d):)?id:((?:[\w\d_]+)(?::(?:\d+|about))?)/n
        m = Regexp.last_match
        @elems.push Hatena::ID.new(m[1], m[2], true)
      when /\A\[(ISBN|ASIN|isbn|asin):(.*?)(:image(:(small|large))?)?\]/m, /(ISBN|ASIN|isbn|asin):([\-0-9A-Za-z]+)(:image(:(small|large))?)?/
        @elems.push Hatena::Amazon.new(Regexp.last_match[2], true)
      when /\A\[tex:(.*?)\]/m
        @elems.push Hatena::TeX.new(Regexp.last_match[1])
      when /\Ag:[\w\d_]+/n
        @elems.push Hatena::Group.new(Regexp.last_match[0], true)
      when /\A\[((?:https?|ftp|mailto).*?)\]/m, /\A(#{URI.regexp})/o
        @elems.push Hatena::URI.new(Regexp.last_match[1])
      else
        /.+?(?=[\[\]\(\)\<\>]|https?|ftp|mailto|id|ISBN|ASIN|a:|d:|g:|$)/m =~ str
        if inside_a
          @elems.push Hatena::CDATA.new(Regexp.last_match.to_s)
        else
          @elems.push Hatena::Sentence.new(Regexp.last_match.to_s)
        end
      end
      str = Regexp.last_match.post_match
    end
  end

  def convert(mode)
    @elems.inject('') {|r, i| r << i.convert(mode) }
  end

  private
  # tag_regex was quoted from http://www.din.or.jp/~ohzaki/perl.htm#HTML_Tag
  def tag_regex
    /<[^"'<>]*(?:"[^"]*"[^"'<>]*|'[^']*'[^"'<>]*)*(?:>|(?=<)|$)/
  end
end

# String that surely doesn't contain any keywords
# String that can contain keyword is a Sentence
class Hatena::CDATA
  def initialize(str)
    @str = str.freeze
  end

  def convert(mode)
    @str
  end
end

# footnote
# footnote.rb required
class Hatena::Footnote
  def initialize(str)
    @str = str
    @heredoc = rand(0x100000000)
  end

  def convert(mode)
    sprintf("<%%=fn <<'%0.32b'.chomp\n%s\n%0.32b\n%%>", @heredoc, @str, @heredoc)
  end
end

# HTML tags
# Disadvantanegs from hatena : <hatena ...> is not supported
# Extension to Hatena : ERB expression can be written
class Hatena::TAG
  def initialize(str)
    @elems = Array.new
    return if /<hatena/ =~ str  # not implemented
    while m = /"(.*?)"/.match(str)
      @elems.push Hatena::CDATA.new(m.pre_match)
      @elems.push Hatena::CDATA.new('"')
      case m[1]
      when /\Agoogle:(.*)/
        @elems.push Hatena::Google.new(Regexp.last_match[1], false)
      when /\Aid:(.*)/
        @elems.push Hatena::ID.new(Regexp.last_match[1], false)
      when /\A(ISBN|ASIN|isbn|asin):(.*)/
        @elems.push Hatena::Amazon.new(Regexp.last_match[2], false)
      when /\Akeyword:(.*)/
        @elems.push Hatena::Keyword.new(Regexp.last_match[1], false)
      else
        @elems.push Hatena::CDATA.new(m[1])
      end
      @elems.push Hatena::CDATA.new('"')
      str = m.post_match
    end
    @elems.push Hatena::CDATA.new(str)
  end

  def convert(mode)
    @elems.inject('') {|r, i| r << i.convert(mode) }
  end
end

# URIs which appear in the sentence
class Hatena::URI
  def initialize(str)
    @uri = str
  end

  def convert(mode)
    template = nil
    if mode == :CHTML
      template = '<A HREF="%s">%s</A>'
    else
      template = '<a href="%s">%s</a>'
    end
    sprintf(template, @uri, @uri)
  end
end

# Link to Google
class Hatena::Google
  def initialize(str, tag_p)
    @tag_p = tag_p
    @str = str
  end

  def convert(mode)
    uri = 'http://www.google.com/search?q=%s&ie=euc-jp&oe=euc-jp' % URI.escape(@str)
    return uri unless @tag_p
    template=nil
    if mode == :CHTML
      template = '<A HREF="%s">google:%s</A>'
    else
      template = '<a href="%s">google:%s</a>'
    end
    sprintf(template, uri, @str)
  end
end

# Link to Hatena Group
class Hatena::Group
  def initialize(name, tag_p)
    @name = name[2..-1]
    @tag_p = tag_p
  end

  def convert(mode)
    uri = 'http://%s.g.hatena.ne.jp/' % @name
    return uri unless @tag_p
    template=nil
    if mode == :CHTML
      template = '<A HREF="%s">g:%s</A>'
    else
      template = '<a href="%s">g:%s</a>'
    end
    sprintf(template, uri, @name)
  end
end

# Link to Hatena keyword
class Hatena::Keyword
  def initialize(group, str, tag_p)
    @group = if group then
               Hatena::Group.new(group, false).convert(nil)
             else
               'http://d.hatena.ne.jp/'
             end
    @str = str
    @tag_p = tag_p
  end

  def convert(mode)
    uri = '%skeyword/%s' % [@group, URI.escape(@str)]
    return uri unless @tag_p
    template=nil
    if mode == :CHTML
      template = '<A HREF="%s">%s</A>'
    else
      template = '<a href="%s" class="keyword">%s</a>'
    end
    sprintf(template, uri, @str)
  end
end

# Link to Hatena hosted diary
class Hatena::ID
  def initialize(type, str, tag_p)
    @type = type || 'd'
    @str = type ? type + ":id:" + str : 'id:' + str
    @name, @date = *str.split(/:/,2)
    @tag_p = tag_p
  end

  def convert(mode)
    uri = case @type
          when /\Ag/ then
            Hatena::Group.new(@type, false).convert(mode)
          when 'a', 'd' then
            'http://%s.hatena.ne.jp/' % @type
          end
    uri << @name << '/'
    uri << @date if @date &&! @date.empty?
    return uri unless @tag_p
    template=nil
    if mode == :CHTML
      template = '<A HREF="%s">%s</A>'
    else
      template = '<a href="%s">%s</a>'
    end
    sprintf(template, uri, @str)
  end
end

# ISBN & ASIN
# amazon.rb is required
class Hatena::Amazon
  def initialize(str, tag_p)
    @str = str.split(/:/)[0]
    @tag_p = tag_p
  end

  def convert(mode)
    if @tag_p
      sprintf('<%%=isbn_image "%s", "isbn:%s"%%>', @str, @str.gsub(/\-/, '')) # %=
    else
      sprintf('http://www.amazon.co.jp/exec/obidos/ASIN/%s/%s',
              @str,
              Hatena.conf['amazon.aid'] || '')
    end
  end
end

# Amazon search
# http://d.hatena.ne.jp/hatenadiary/20040310#1078879113
class Hatena::AmazonSearch
  def initialize(str, tag_p)
    @str = str
    @tag_p = tag_p
  end

  def convert(mode)
    uri = 'http://www.amazon.co.jp/exec/obidos/external-search?mode=blended&amp;tag=%s&amp;encoding-string-jp=%%c6%%fc%%cb%%dc%%b8%%ec&amp;keyword=%s' % [Hatena.conf['amazon.aid'] || '', URI.escape(@str)]
    return uri unless @tag_p
    template=nil
    if mode == :CHTML
      template = '<A HREF="%s">amazon:%s</A>'
    else
      template = '<a href="%s">amazon:%s</a>'
    end
    sprintf(template, uri, @str)
  end
end

# TeX expressoin
# texdiary http://kumamushi.org/~k/texdiary/ required
class Hatena::TeX
  def initialize(expr)
    @expr
  end

  def convert(mode)
    sprintf('<%%=eq "%s"%%>' % @expr) #%=
  end
end

# String that can contain keywords
# String that cannot contain keywords is a CDATA
class Hatena::Sentence
  def initialize(str)
    @elems = Array.new
    return if str.nil? || str.empty?
    if false # kw = Hatena::API.keywords.match(str)
      m = Regexp.new(Regexp.quote(kw)).match(str)
      @elems.push Hatena::CDATA.new(m.pre_match)
      @elems.push Hatena::Keyword.new(nil, kw, true)
      @elems.push Hatena::Sentence.new(m.post_match)
    else
      @elems.push Hatena::CDATA.new(str)
    end
  end

  def convert(mode)
    @elems.inject('') {|r, i| r << i.convert(mode) }
  end
end

# Local Variables:
# mode: ruby
# code: euc-jp-unix
# End:


