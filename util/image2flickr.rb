#!/usr/bin/env ruby
# = Image2Flickr
#   imageプラグインからflickrプラグインへのマイグレーションツール
#
# Author:: MATSUOKA Kohei <http://www.machu.jp/>
# Copyright:: Copyright (c) MATSUOKA Kohei <http://www.machu.jp/>
# License:: GPL <http://www.gnu.org/copyleft/gpl.html>
#
# USEGE:
#   imageプラグインからflickrプラグインへ移行するためのツールです。
#   このツールの機能は、以下の2つです。
#   (1) tDiaryのimageプラグインを利用して日記に載せた写真を、
#       Flickrへアップロードします。
#   (2) 日記データのimageプラグインの呼び出しを、
#       flickrプラグインへと置き換えます。
#       古い日記データは .bak.YYYYmmddHHMMSS を付けてバックアップします。
#
#   == 注意
#
#   (1) tDiary2.3.1以降が対象です。
#       日記データがUTF-8に変換されている必要があります。
#   (2) Wiki記法で記述された日記が対象です。
#
#
#   == 移行手順
#
#   1. Flickr APIキーの取得
#
#   flickr.comのAPIサイトにアクセスし、"Apply for a new API Key"にて
#   新しいAPIキーを生成します。
#   http://www.flickr.com/services/api/keys/
#
#   Authentication TypeはAuthentication Typeを選択してください。
#
#
#   2. tDiaryデータフォルダのバックアップ
#
#   このマイグレーションツールはtDiaryの日記データを書き換えます。
#   古い日記データを残す仕様ですが、万が一に備えて
#   事前にtDiaryのデータフォルダをバックアップしてください。
#
#
#   3. rflickrライブラリの取得
#
#   このマイグレーションツールはFlickrへの写真のアップロードに
#   rflickrライブラリを使用します。
#   以下のサイトからrflickrライブラリを取得して、インストールしてください。
#   http://rubyforge.org/projects/rflickr/
#
#   RubyGemsが利用できる場合は、以下のコマンドでインストールできます。
#   $ gem install rflickr
#
#
#   4. マイグレーションツールの設定
#
#   image2flickr.rbをエディタで開き、以下の4つのパラメータを設定します。
#
#   # FlickrのAPIキー
#   @api_key = '123456789012345678901234567890'
#   # Flickr APIのシークレットキー
#   @secret = '1234567890'
#   # tDiaryのデータフォルダ
#   @data_path = '/var/tdiary'
#   # tDiaryのイメージフォルダ
#   @image_dir = '/var//www/tdiary/images'
#
#
#   5. マイグレーションツールの実行
#
#   tDiaryのデータフォルダに書き込む権限を持つアカウントで、
#   コマンドラインからimage2flickr.rbを実行してください。
#   $ ./image2flickr
#
#   すると、以下のメッセージが表示されます。
#   ----
#   Flickrへ写真をアップロードするためのトークンを取得します。
#   Webブラウザで下記のURLへアクセスしたら、何かキーを押してください。
#   http://flickr.com/services/auth/?api_sig=....
#   ----
#
#   指定されたURLへWebブラウザでアクセスし、トークンの発行を許可してください。
#   コマンドラインへ戻り何かキーを押すと、マイグレーションが始まります。
#
#   なお、ツールを途中で中断し、2回目に実行するときはトークンを取得する
#   必要はありません。
#
#
#   6. 実行結果の確認
#
#   ツールが終了したらtDiaryのデータフォルダを開き、
#   imageプラグインの呼び出しがflickrプラグインの呼び出しへ
#   置き換わっていることを確認してください。
#   古い日記データは .bak.20081024090000 などの拡張子がついて
#   バックアップされていますので、問題があれば元に戻してください。
#
#   ツールを実行すると、以下の2つのファイルが作成されます。
#   (1) flickr.token
#       Flickrへ写真をアップロードするためのトークン。
#   (2) image2flickr.yaml
#       tDiaryのイメージフォルダに存在するJPEGファイル (ex. 20081025_0.jpg) と
#       Flickrへアップロードしたphoto_idの対応付けを記録したファイル。
#
#   これらのファイルは、マイグレーションツールを途中で中断したときのために
#   用意されています。
#   マイグレーションが完了したら、少なくともflickr.tokenは削除してください。
#   （トークンの不正利用を防ぐためです）
#
#
$KCODE = 'utf8'
begin
  require 'rubygems'
  gem 'rflickr'
rescue
end
require 'flickr'
require 'yaml/store'
require 'tempfile'
require 'fileutils'

# FlickrのAPIキー
@api_key = '123456789012345678901234567890'
# Flickr APIのシークレットキー
@secret = '1234567890'
# tDiaryのデータフォルダ
@data_path = '/var/tdiary'
# tDiaryのイメージフォルダ
@image_dir = '/var/www/tdiary/images'


def main
  uploader = FlickrUploder.new('image2flickr.yaml', 'flickr.token', @api_key, @secret)
  parser = TDiaryParser.new(@data_path)
  i2f = Image2Flickr.new(parser, uploader, @image_dir)
  # tDiaryのimagesフォルダから対象日記を取得
  files = Dir.glob("#{@image_dir}/*.{jp{,e}g,png,gif}").map{|file|
    File.basename(file).match(/^(\d{6})/)
    $1
  }.compact.uniq
  # 対象日記を変換
  files.each do |file|
    i2f.convert(file)
  end

  # cache のクリア
  Dir["#{@data_path}/cache/*.rb"].each{|f| FileUtils.rm_f( f )}
  Dir["#{@data_path}/cache/*.parser"].each{|f| FileUtils.rm_f( f )}
end

# Flickrへ写真をアップロードし、元ファイル名とphoto_idのペアをYAMLに記録する
class FlickrUploder
  def initialize(yaml, token, api_key, secret)
    @flickr = Flickr.new(token, api_key, secret)
    # トークンが無ければ取得する
    unless @flickr.auth.token
      puts "Flickrへ写真をアップロードするためのトークンを取得します。"
      puts "Webブラウザで下記のURLへアクセスしたら、何かキーを押してください。"
      puts @flickr.auth.login_link
      # キー入力待ち
      gets
      @flickr.auth.getToken
      @flickr.auth.cache_token
      puts "トークンを取得し、#{token} へ保存しました。"
      puts
    end

    @db = YAML::Store.new(yaml)
    @db.transaction {
      @db['photos'] ||= {}
    }
  end

  # Flickrへ写真をアップロードする
  def upload(file, title)
    id = 0
    @db.transaction {
      basename = File.basename(file)
      if @db['photos'][basename]
        # アップロード済みの場合はスキップ
        STDERR.puts "passed updating #{basename} (#{title}) ..."
        id = @db['photos'][basename]
        @db.abort
      else
        # 写真をアップロードする
        STDERR.puts "updating #{basename} (#{title}) ..."
        id = @flickr.photos.upload.upload_file(file, title)
        @db['photos'][basename] = id
      end
    }
    id
  end
end

class TDiaryParser
  include FileUtils

  def initialize(data_path)
    @data_path = data_path
  end

  # tDiaryの日記を置換する
  # 拡張子に ".bak.yyyymmddHHMMSS" を付けて日記データをバックアップする
  def each_diary(yearmonth)
    yearmonth.match(/(\d{4})(\d{2})/)
    year = $1
    month = $2
    file = "#{@data_path}/#{year}/#{yearmonth}.td2"
    # ファイルをバックアップ
    backup = "#{file}.bak.#{Time.now.strftime('%Y%m%d%H%M%S')}"
    cp(file, backup, :preserve => true)
    # 一時ファイルを生成
    tmp = Tempfile.new('tmp')
    open(file) do |fin|
      fin.each('') do |headers|
        date = headers.grep(/^Date:\s*(\d{4}\d{2}\d{2})/){$1}[0]
        diary = fin.gets("\n.\n")
        diary = yield(date, diary)
        tmp.print headers
        tmp.print diary
      end
    end
    tmp.close
    cp(tmp.path, file)
  end
end

class Image2Flickr
  def initialize(parser, uploader, image_dir)
    @parser = parser
    @uploader = uploader
    @image_dir = image_dir
  end

  # imageプラグインをflickrプラグインへ置き換える
  def convert(yearmonth)
    @parser.each_diary(yearmonth) do |@date, diary|
      # 現在はWiki記法のみ対応
      diary.gsub!(/\{\{(image[^}]+)\}\}/) {|match|
        begin
          STDERR.puts "found: #{match}"
          # image, image_left, image_right のいずれかに対応
          replace = "{{#{eval($1)}}}"
          STDERR.puts "replace: #{replace}"
          STDERR.puts
          replace
        rescue => e
          # 例外が発生したら置換しない
          STDERR.puts "ERROR: #{e}"
          STDERR.puts
          match
        end
      }
      diary
    end
  end

  def image( index, title = nil, thumbnail = nil, size = nil, place = 'photo' )
    replace("flickr", @date, index, title)
  end

  def image_center( index, title = nil, thumbnail = nil, size = nil, place = 'photo' )
    replace("flickr", @date, index, title)
  end

  def image_left( index, title = nil, thumbnail = nil, size = nil, place = 'photo' )
    replace("flickr_left", @date, index, title)
  end

  def image_right( index, title = nil, thumbnail = nil, size = nil, place = 'photo' )
    replace("flickr_right", @date, index, title)
  end

  def replace(method, date, index, title)
    file = Dir.glob("#{@image_dir}/#{date}_#{index}.{jpg,png,gif}").shift
    # タイトルが未指定の場合はファイル名
    title ||= File.basename(file)
    id = @uploader.upload(file, title)
    "#{method} #{id}"
  end
end

main
