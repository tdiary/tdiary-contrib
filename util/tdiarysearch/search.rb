#!/usr/bin/env ruby
#
# tdiarysearch
#
# Copyright (C) 2003-2005 Minero Aoki
#
# This program is free software.
# You can distribute/modify this program under the terms of
# the GNU GPL, General Public License version 2.
#
# $originalId: search.rb,v 1.14 2005/07/27 07:16:07 aamine Exp $
#
# Project home page: http://i.loveruby.net/w/tdiarysearch.html
#

#
# Static Configurations
#

LOGGING = false
LOGFILE_NAME = 'search.log'
DEBUG = $DEBUG

#
# HTML Templates
#

def unindent(str, n)
  str.gsub(/^ {0,#{n}}/, '')
end

HEADER = unindent(<<-'EOS', 2)
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
  <html lang="ja-JP">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=euc-jp">
    <meta http-equiv="Content-Language" content="ja-JP">
    <meta name="robots" content="noindex">
    <link rel="stylesheet" href="theme/base.css" type="text/css" media="all">
    <link rel="stylesheet" href="theme/<%= theme %>/<%= theme %>.css" title="<%= theme %>" type="text/css" media="all">
    <title>tDiary Search</title>
  </head>
  <body>
EOS

FOOTER = unindent(<<'EOS', 2)
  </body>
  </html>
EOS

SEARCH_FORM = unindent(<<"EOS", 2)
  <form method="post" action="#{File.basename(__FILE__)}">
  <input type="text" name="q" size="20" value="<%= patterns.map {|re| escape(re.source) }.join(' ') %>">
  <input type="submit" value="Search">
  <%
      if theme
  %><input type="hidden" name="theme" value="on"><%
      end
  %>
  </form>
EOS

SEARCH_PAGE = unindent(<<-"EOS", 2)
  <h1>tDiary Search</h1>
  #{SEARCH_FORM}
EOS

TOO_MANY_HITS = 50

SEARCH_RESULT = unindent(<<-"EOS", 2)
  <h1>tDiary Search: Search Result</h1>
  #{SEARCH_FORM}
  <%
      nhits = 0
      toomanyhits = false
      match_components(patterns) {|diary, fragment, component|
        nhits += 1
        if nhits > TOO_MANY_HITS
          toomanyhits = true
          break
        end
  %>
  <div class="day">
  <h2><a href="<%= @config.index %>?date=<%= diary.ymd %>#<%= fragment %>"><%= diary.y_m_d %></a></h2>
  <div class="body">
  <div class="section">
  <p><%= short_html(component) %></p>
  </div>
  </div>
  </div><%
      }
  %>
  <p><%= toomanyhits ? 'too many hits.' : nhits.to_s+' hits.' %></p>
  #{SEARCH_FORM}
EOS

SEARCH_ERROR = unindent(<<"EOS", 2)
  #{SEARCH_FORM}
  <%= escape(reason) %>.
EOS

HISTORY = unindent(<<"EOS", 2)
  <h1>tDiary Search: Search History</h1>
  #{SEARCH_FORM}
  <ul>
  <%
      recent_queries.sort_by {|t,q| -t.to_i }.each do |time, query|
  %><li><%= time.strftime('%Y-%m-%d %H:%M:%S') %> | <a href="#{File.basename(__FILE__)}?q=<%= escape_url(query) %>"><%= escape(query) %></a></li>
  <%
      end
  %></ul>
  #{SEARCH_FORM}
EOS

#
# Main
#

if File.symlink?(__FILE__)
  tdiarylib = File.dirname(File.readlink(__FILE__))
else
  tdiarylib = File.dirname(__FILE__)
end
$:.unshift tdiarylib
require 'tdiary'
require 'tdiary/defaultio'
require 'erb'

class WrongQuery < StandardError; end

Z_SPACE = "\241\241"   # zen-kaku space

BEGIN { $defout.binmode }

def main
  $KCODE = 'EUC'
  cgi = CGI.new
  @config = TDiary::Config.new(cgi)
  @config.options['apply_plugin'] = true
  html = '<html><head><title></title></head><body><p>error</p></body></html>'
  begin
    html = generate_page(cgi)
  ensure
    send_html cgi, html
  end
  exit 0
end

def generate_page(cgi)
  query = nil
  begin
    theme = @config.theme
    if LOGGING and File.file?(query_log()) and cgi.valid?('history')
      return history_page(theme)
    end
    begin
      return search_form_page(theme) unless cgi.valid?('q')
      initialize_tdiary_plugins cgi
      query = @config.to_native([cgi.params['q']].flatten.compact.join(' '))
      patterns = setup_patterns(query)
      html = search_result_page(theme, patterns)
      save_query(query, query_log()) if LOGGING
      return html
    rescue WrongQuery => err
      return search_error_page(theme, (patterns || []), err.message)
    end
  rescue Exception => err
    html = ''
    html << HEADER
    html << "<pre>\n"
    html << 'q=' << escape(query) << "\n" if query
    html << escape(err.class.name) << "\n" if DEBUG
    html << escape(err.message) << "\n"
    html << err.backtrace.map {|i| escape(i) }.join("\n") if DEBUG
    html << "</pre>\n"
    html << FOOTER
    return html
  end
end

def send_html(cgi, html)
  print cgi.header('status' => '200 OK',
                   'type' => 'text/html',
                   'charset' => 'euc-jp',
                   'Content-Length' => html.length.to_s,
                   'Cache-Control' => 'no-cache',
                   'Pragma' => 'no-cache')
  print html unless cgi.request_method == 'HEAD'
end

def setup_patterns(query)
  patterns = split_string(query).map {|pat|
    check_pattern pat
    /#{Regexp.quote(pat)}/ie
  }
  raise WrongQuery, 'no pattern' if patterns.empty?
  raise WrongQuery, 'too many sub patterns' if patterns.length > 8
  patterns
end

def check_pattern(pat)
  raise WrongQuery, 'no pattern' unless pat
  raise WrongQuery, 'empty pattern' if pat.empty?
  raise WrongQuery, "pattern too short: #{pat}" if pat.length < 2
  raise WrongQuery, 'pattern too long' if pat.length > 128
end

def split_string(str)
  str.split(/[\s#{Z_SPACE}]+/oe).reject {|w| w.empty? }
end

def save_query(query, file)
  File.open(file, 'a') {|f|
    begin
      f.flock(File::LOCK_EX)
      f.puts "#{Time.now.to_i}: #{query.dump}"
    ensure
      f.flock(File::LOCK_UN)
    end
  }
end

#
# eRuby Dispatchers and Helper Routines
#

def search_form_page(theme)
  patterns = []
  ERB.new(HEADER + SEARCH_FORM + FOOTER).result(binding())
end

def search_result_page(theme, patterns)
  ERB.new(HEADER + SEARCH_RESULT + FOOTER).result(binding())
end

def search_error_page(theme, patterns, reason)
  ERB.new(HEADER + SEARCH_ERROR + FOOTER).result(binding())
end

def history_page(theme)
  patterns = []
  ERB.new(HEADER + HISTORY + FOOTER).result(binding())
end

def query_log
  "#{@config.data_path}#{LOGFILE_NAME}"
end

N_SHOW_QUERY_MAX = 20

def recent_queries
  return unless File.file?(query_log())
  File.readlines(query_log()).reverse[0, N_SHOW_QUERY_MAX].map {|line|
    time, q = *line.split(/:/, 2)
    [Time.at(time.to_i), eval(q)]
  }
end

INF = 1 / 0.0

def match_components(patterns)
  foreach_diary_from_latest do |diary|
    next unless diary.visible?
    num = 1
    diary.each_section do |sec|
      if patterns.all? {|re| re =~ sec.to_src }
        yield diary, fragment('p', num), sec
      end
      num += 1
    end
    diary.each_visible_comment(INF) do |cmt, num|
      if patterns.all? {|re| re =~ cmt.body }
        yield diary, fragment('c', num), cmt
      end
    end
  end
end

def fragment(type, num)
  sprintf('%s%02d', type, num)
end

#
# tDiary Implementation Dependent
#

def foreach_diary_from_latest(&block)
  foreach_data_file(@config.data_path.sub(%r</+\z>, '')) do |path|
    read_diaries(path).sort_by {|diary| diary.date }.reverse_each(&block)
  end
end

def foreach_data_file(data_path, &block)
  Dir.glob("#{data_path}/[0-9]*/*.td2").sort.reverse_each do |path|
    yield path.untaint
  end
end

def read_diaries(path)
  d = nil
  diaries = {}
  load_tdiary_textdb(path) do |header, body|
    d = diary_class(header['Format']).new(header['Date'], '', body)
    d.show(header['Visible'] != 'false')
    diaries[d.ymd] = d
  end
  (Years[d.y] ||= []).push(d.m) if d
  load_comments diaries, path
  diaries.values
end

DIARY_CLASS_CACHE = {}

def diary_class(style)
  c = DIARY_CLASS_CACHE[style]
  return c if c
  require "tdiary/#{style.downcase}_style.rb"
  c = eval("TDiary::#{style.capitalize}Diary")
  c.__send__(:include, DiaryClassDelta)
  DIARY_CLASS_CACHE[style] = c
  c
end

module DiaryClassDelta
  def ymd
    date().strftime('%Y%m%d')
  end

  def y_m_d
    date().strftime('%Y-%m-%d')
  end

  def y
    '%04d' % date().year
  end

  def m
    '%02d' % date().month
  end
end

def load_comments(diaries, path)
  cmtfile = path.sub(/2\z/, 'c')
  return unless File.file?(cmtfile)
  load_tdiary_textdb(cmtfile) do |header, body|
    c = TDiary::Comment.new(header['Name'], header['Mail'], body,
                            Time.at(header['Last-Modified'].to_i))
    c.show = (header['Visible'] != 'false')
    d = diaries[header['Date']]
    d.add_comment c if d
  end
end

def load_tdiary_textdb(path)
  File.open(path) {|f|
    ver = f.gets.strip
    raise "unkwnown format: #{ver}" unless ver == 'TDIARY2.00.00'
    f.each('') do |header|
      h = {}
      header.untaint.strip.each do |line|
        n, v = *line.split(':', 2)
        h[n.strip] = v.strip
      end
      yield h, f.gets("\n.\n").chomp(".\n").untaint
    end
  }
end

def short_html(component)
  # Section classes do not have common superclass, we can't use class here.
  case component.class.name
  when /Section/
    section = component
    if section.subtitle
      sprintf('%s<br>%s',
              tdiary2text(section.subtitle_to_html),
              tdiary2text(section.body_to_html))
    else
      tdiary2text(section.body_to_html)
    end
  when /Comment/
    cmt = component
    escape((cmt.name + ': ' + cmt.body).slice(/\A.{0,120}/me))
  else
    raise "must not happen: #{component.class}"
  end
end

def tdiary2text(html)
  apply_tdiary_plugins(html).gsub(%r[<.*?>]em, '').slice(/\A.{0,120}/me)
end

Years = {}

TDiary::Plugin.__send__(:public, :apply_plugin)
def apply_tdiary_plugins(html)
  @plugin.apply_plugin(html, false)
end

@plugin = nil

def initialize_tdiary_plugins(cgi)
  @plugin = TDiary::Plugin.new('conf' => @config,
                               'mode' => 'month',
                               'secure' => false,
                               'diaries' => {},
                               'cgi' => cgi,
                               'index' => @config.index,
                               'years' => Years,
                               'cache_path' => @config.cache_path ||
                                               @config.data_path)
end

#
# Utils
#

HTML_ESCAPE_TABLE = {
  '&' => '&amp;',
  '<' => '&lt;',
  '>' => '&gt;',
  '"' => '&quot;'
}

def escape(str)
  tbl = HTML_ESCAPE_TABLE
  str.gsub(/[&"<>]/) {|ch| tbl[ch] }
end

def escape_url(u)
  escape(urlencode(u))
end

def urlencode(str)
  str.gsub(/[^\w\-]/n) {|ch| sprintf('%%%02x', ch[0]) }
end

#
# Old Ruby Compatibility
#

if RUBY_VERSION < '1.8.0'
  class String
    remove_method :slice
    def slice(re, n = 0)
      m = re.match(self) or return nil
      m[n]
    end
  end
end

unless Array.method_defined?(:all?)
  module Enumerable
    def all?
      each do |i|
        return false unless yield(i)
      end
      true
    end
  end
end

unless Array.method_defined?(:sort_by)
  module Enumerable
    def sort_by
      map {|i| [yield(i), i] }.sort.map {|val, i| i }
    end
  end
end

unless MatchData.method_defined?(:captures)
  class MatchData
    def captures
      to_a()[1..-1]
    end
  end
end

main
