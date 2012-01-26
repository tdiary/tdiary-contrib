#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# $Id$
#
# Copyright (C) 2003,2004 Minero Aoki <aamine@loveruby.net>
#
# This program is free software.
# You can distribute/modify this program under the terms of
# the GNU LGPL, Lesser General Public License version 2.1.
#

TDIARY_DATA_PATH = nil
CGI_URL = './'
LOGGING = true
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
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="Content-Language" content="ja-JP">
    <meta name="robots" content="none">
    <title>tDiary Grep</title>
  </head>
  <body>
EOS

FOOTER = unindent(<<'EOS', 2)
  </body>
  </html>
EOS

SEARCH_FORM = unindent(<<"EOS", 2)
  <form method="post" action="#{File.basename(__FILE__)}">
  <p>% fgrep -i '<input type="text" name="q" size="20" value="">' */*.td2
  <input type="submit" value="Return"></p>
  </form>
EOS

SEARCH_RESULT = unindent(<<-'EOS', 2) + SEARCH_FORM
  <pre>
  % fgrep -i '<%= patterns.map {|re| escape(re.source) }.join(' ') %>' */*.td2
  <%
      toomanyhits = match_sections(patterns) {|section|
  %><a href="<%= section.url %>"><%= format_date(section.date)
  %></a>: <%= escape(section.short_text) %>
  <%
      }
  %><%= toomanyhits ? 'too many hits.' : ''
  %></pre>
EOS

SEARCH_ERROR = unindent(<<'EOS', 2) + SEARCH_FORM
  <pre>
  % fgrep -i '<%= escape(query) %>' */*.td2
  <%= escape(reason) %>.
  </pre>
EOS

HISTORY = unindent(<<"EOS", 2)
  <pre>
  <%
      cmd = ['ls', 'cd .', 'cvsdiffl', 'ps -ef', 'w', './configure --help',
             'date', 'make', 'echo $?', 'vi log', 'jobs', 'cvs up', 'who']
      recent_queries.sort_by {|t,q| t }.each do |time, query|
        n = rand(100)
        if n < cmd.size
  %><%= time.to_i - 10 %>: <%= cmd[n] %>
  <%    end
  %><%= time.to_i %>: fgrep -i '<a href="#{File.basename(__FILE__)}?q=<%= escape_url(query) %>"><%= escape(query) %></a>' */*.td2
  <%
      end
  %></pre>
#{SEARCH_FORM}
EOS

#
# Load Libraries
#

require 'cgi'

class CGI
  def valid?(name)
    self.params[name] and self.params[name][0]
  end
end

require 'erb'
require 'uri'

# borrowed from tdiary
require 'nkf'
begin
  require 'uconv'

  def Uconv.unknown_unicode_handler(unicode)
    if unicode == 0xff5e
      "～"
    else
      raise Uconv::Error
    end
  end

  def to_euc(str)
    begin
      Uconv.u8toeuc(str)
    rescue Uconv::Error
      NKF::nkf('-w -m0', str)
    end
  end
rescue LoadError
  def to_euc(str)
    NKF::nkf('-w -m0', str)
  end
end

#
# Main
#

class TDiaryGrepError < StandardError; end
class WrongQuery < TDiaryGrepError; end
class InvalidTDiaryFormat < TDiaryGrepError; end
class ConfigError < TDiaryGrepError; end

Z_SPACE = "　"   # zen-kaku space

BEGIN { $stdout.binmode }

def main
  cgi = CGI.new
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
    begin
      if LOGGING and File.file?(query_log()) and cgi.valid?('history')
        return history_page()
      elsif not cgi.valid?('q')
        return search_form_page()
      else
        query = [cgi.params['q']].compact.flatten.join(' ')
        html = search_result_page(setup_patterns(query))
        save_query(query, query_log()) if LOGGING
        return html
      end
    rescue WrongQuery => err
      return search_error_page(query, err.message)
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
                   'charset' => 'UTF-8',
                   'Content-Length' => html.length.to_s,
                   'Cache-Control' => 'no-cache',
                   'Pragma' => 'no-cache')
  print html unless cgi.request_method == 'HEAD'
end

def setup_patterns(query)
  patterns = split_string(query).map {|pat|
    check_pattern pat
    /#{Regexp.quote(pat)}/iu
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
  str.split(/[\s#{Z_SPACE}]+/ou).reject {|w| w.empty? }
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

def read_query_logs(file)
  File.open(file) {|f|
    begin
      f.flock(File::LOCK_SH)
      return f.readlines
    ensure
      f.flock(File::LOCK_UN)
    end
  }
end

def query_log
  "#{tdiary_data_path()}/grep.log"
end

#
# eRuby Dispatchers and Helper Routines
#

def search_form_page
  patterns = []
  ERB.new(HEADER + SEARCH_FORM + FOOTER).result(binding())
end

def search_result_page(patterns)
  ERB.new(HEADER + SEARCH_RESULT + FOOTER).result(binding())
end

def search_error_page(query, reason)
  ERB.new(HEADER + SEARCH_ERROR + FOOTER).result(binding())
end

def history_page
  patterns = []
  ERB.new(HEADER + HISTORY + FOOTER).result(binding())
end

N_SHOW_QUERY_MAX = 20

def recent_queries
  return unless File.file?(query_log())
  read_query_logs(query_log()).reverse[0, N_SHOW_QUERY_MAX].map {|line|
    time, q = *line.split(/:/, 2)
    [Time.at(time.to_i), eval(q)]
  }
end

def format_time(time)
  sprintf('%04d-%02d-%02d %02d:%02d:%02d',
          time.year, time.month, time.day,
          time.hour, time.min, time.sec)
end

def format_date(ymd)
  y, m, d = /\A(\d{4})(\d{2})(\d{2})/.match(ymd).captures
  "#{y}-#{m}-#{d}"
end

TOO_MANY_HITS = 50

def match_sections(patterns)
  hit = 0
  match_sections0(patterns) do |section|
    yield section
    hit += 1
    return true if hit > TOO_MANY_HITS
  end
  false
end

def match_sections0(patterns)
  foreach_data_file(tdiary_data_path()) do |path|
    read_diaries(path).sort_by {|diary| diary.date }.reverse_each do |diary|
      diary.each_section do |section|
        yield section if patterns.all? {|re| re =~ section.source }
      end
    end
  end
end

#
# tDiary Implementation Dependent
#

def foreach_data_file(data_path, &block)
  Dir.glob("#{data_path}/[0-9]*/*.td2").sort.reverse_each(&block)
end

def read_diaries(path)
  diaries = []
  File.open(path, :encoding => 'UTF-8') {|f|
    f.each('') do |header|
      diaries.push Diary.parse(header, f.gets("\n.\n").chomp(".\n"))
    end
  }
  diaries
end

class Diary
  def Diary.parse(header, body)
    ymd = header.slice(/^Date:\s*(\d{4}\d{2}\d{2})/, 1) or
        raise "unexpected tdiary format: Date=nil:\n#{header.strip}"
    format = header.slice(/^Format:\s*(\S+)/, 1) or
        raise "unexpected tdiary format: Format=nil:\n#{header.strip}"
    visible = case header.slice(/^Visible:\s*(\S+)/, 1)
              when 'true'  then true
              when 'false' then false
              when nil     then true
              else
                raise 'must not happen (parsing Visible:)'
              end
    new(ymd, visible, split_sections(body, format))
  end

  SPLITTER = {
    'tdiary'   => /\n\n/,
    'rd'       => /^=(?!=)/,
    'wiki'     => /^!/,
    'blog'     => /\n\n/,
    'blogrd'   => /^=(?!=)/,
    'blogwiki' => /^!/
  }

  def Diary.split_sections(diary, format)
    re = SPLITTER[format.downcase] or
        raise ArgumentError, "unknown diary format: #{format}"
    diary.strip.split(re)
  end
  private_class_method :split_sections

  def initialize(ymd, visible, section_texts)
    @date = ymd
    @visible = visible
    @sections = []
    section_texts.each_with_index do |src, idx|
      @sections.push DiarySection.new(self, idx + 1, src)
    end
  end

  attr_reader :date

  def each_section(&block)
    return unless @visible
    @sections.each(&block)
  end
end

class DiarySection
  def initialize(day, num, src)
    @day = day
    @number = num
    @source = src
  end

  def inspect
    "\#<#{self.class} #{@day.date}.#{@number}>"
  end

  def date
    @day.date
  end

  def format
    @day.format
  end

  attr_reader :source

  def url
    "#{CGI_URL}?date=#{@day.date}\#p#{sprintf('%02d', @number)}"
  end

  def short_text
    title, body = @source.split(/\n/, 2)
    sprintf('%-30s | %s',
            title.to_s.strip,
            remove_tags(body.to_s).gsub(/[\s#{Z_SPACE}]+/ou, ' ').slice(/\A.{0,60}/mu))
  end

  private

  def remove_tags(str)
    str.gsub(/<.*?>|\(\([{|'<]|[>}|']\)\)|\(\(-(?m).*?(?-m)-\)\)/, '')
  end
end

@tdiary_data_path = nil
def tdiary_data_path
  @tdiary_data_path ||= (TDIARY_DATA_PATH || data_path_config())
end

def data_path_config
  tdiary_conf().slice(/^\s*@data_path\s*=\s*(['"])(.*?)\1/, 2) or
      raise ConfigError, 'cannot get tDiary @data_path'
end

@tdiary_conf = nil
def tdiary_conf
  @tdiary_conf ||= File.read("#{File.dirname(__FILE__)}/tdiary.conf", :encoding => 'UTF-8')
end

#
# Utils
#

ESC = {
  '&' => '&amp;',
  '<' => '&lt;',
  '>' => '&gt;',
  '"' => '&quot;'
}

def escape(str)
  str.gsub(/[&"<>]/) {|s| ESC[s] }
end

def escape_url(u)
  escape(URI.encode(u))
end

main
