# SPDX-License-Identifier: MIT
#
# oembed.rb - YouTubeやSpotifyなどが提供する埋め込みタグをoEmbedを利用して取得する
#
# 使い方:
#   日記の中で <%=oembed 'https://www.youtube.com/watch?v=jNQXAC9IVRw' %> などと記述します。
#    <%=oembed 'https://www.youtube.com/watch?v=jNQXAC9IVRw', 500, 200 %> などと書くことで幅や高さを指定することもできます。
#
# オプション:
#   url (required): URL
#   width (optional, number): 埋め込みタグの幅（単位: px）
#   height (optional, number): 埋め込みタグの高さ（単位: px）
#
# 設定:
#   なし
#
# 構築方法:
#   1. nokolexborをインストールします。以下の方法などからインストールできます。
#     - Gemfile.localに`gem 'nokolexbor'`と記述し、`bundle install`を実行する
#     - `gem install nokolexbor` を実行する
# 
# その他:
#   - xml形式でoembedのデータを処理する実装はしていません。
#
# Copyright (c) 2025 eniehack <http://www.eniehack.net/~eniehack>

require "pstore"
require "nokolexbor"
require "open-uri"
require 'json'

def fetch_oembed(endpoint_url, target_url, maxwidth = nil, maxheight = nil)
  params = URI.decode_www_form(endpoint_url.query).to_h
  params["url"] = target_url
  params["format"] = "json" if params["format"].nil?
  params["maxheight"] = maxheight unless maxheight.nil?
  params["maxwidth"] = maxwidth unless maxwidth.nil?
  oembed_url = endpoint_url
  oembed_url.query = URI.encode_www_form(params)
  
  begin
    URI.open(oembed_url,
      'User-Agent' => 'tDiary oEmbed Plugin/1.0',
      read_timeout: 10,
      redirect: false
    ) do |response|
      JSON.parse(response.read, symbolize_names: true)
    end
  rescue OpenURI::HTTPError, JSON::ParserError, Timeout::Error => e
    nil
  end
end

def parse_link_header(link_header, base_url)
  link_pattern = /<([^>]+)>(?:\s*;\s*([^,]+))?/
  
  link_header.split(',').each do |link|
    match = link.strip.match(link_pattern)
    next unless match
    
    url = match[1]
    params_str = match[2] || ''
    
    params = {}
    params_str.scan(/(\w+)=(?:"([^"]+)"|([^;,\s]+))/) do |key, quoted_val, unquoted_val|
      params[key] = quoted_val || unquoted_val
    end
    
    if params['rel'] == 'alternate' && 
       params['type'] == 'application/json+oembed' then
      return URI.join(base_url, url).to_s
    end
  end
  
  nil
end

# HTMLからoEmbedエンドポイントを探す
def discover_oembed_endpoint(url)
  begin
    URI.open(url, 
      'User-Agent' => 'tDiary oEmbed Plugin/1.0',
      read_timeout: 5
    ) do |response|
      if response.meta["link"] then
        link = parse_link_header(response.meta["link"], url)
        return link if link
      end
      doc = Nokolexbor::HTML(response.read)
      link = doc.at_xpath('//link[@rel="alternate" and @type="application/json+oembed"]/@href')
      return link.to_s if link
      nil
    end
  rescue => e
    nil
  end
end

def fallback_html(url)
  %Q|<a href="#{url}">#{url}</a>|
end

def generate_general_oembed_endpoint(url)
  parsed_url = URI.parse(url)
  general_params = URI.decode_www_form(parsed_url.query).filter { |arr| arr[0] != 'url' }.to_h
  general_params['format'] = 'json' unless general_params['format']
  parsed_url.query = URI.encode_www_form(general_params)
  parsed_url
end

def get_oembed_endpoint(url, db)
  uri = URI.parse(url)
  domain = uri.host.downcase
  
  db.transaction do |store|
    store[:endpoints] ||= {}
    cached_endpoint = store[:endpoints][domain]
  
    if cached_endpoint && Time.now < cached_endpoint[:expires_at]
      return URI.parse(cached_endpoint[:url])
    end
  end
  
  # cacheやHTMLなどからoEmbedエンドポイントを探す
  discovered_endpoint = discover_oembed_endpoint(url)
  if discovered_endpoint
    # 相対URLを絶対URLに変換
    discovered_endpoint = URI.join(url, discovered_endpoint).to_s
    
    # ディスカバリー結果をキャッシュに保存（短期間）
    endpoint = generate_general_oembed_endpoint(discovered_endpoint)
    db.transaction do |store|
      store[:endpoints][domain] = {
        url: endpoint,
        discovered_at: Time.now,
        expires_at: Time.now + (3600 * 24 * 7)
      }
    end
    return endpoint
  end
  
  nil
end

def build_html(json, url)
  case json[:type]
  when "rich"
    %Q|<div style="width: #{json[:width]}px;">#{json[:html]}</div>|
  when "video"
    %Q|<div style="width: #{json[:width]}px;">#{json[:html]}</div>|
  when "image"
    %Q|<div style="width: #{json[:width]}px;"><img src="#{json[:url]}" height="#{json[:height]}" width="#{json[:width]}" /></div>|
  when "link"
    %Q|<div><a href="#{url}">#{json[:title]}</a></div>|
  else
    fallback_html(url)
  end
end

def oembed(url, width = nil, height = nil)
  cache_file = "#{@cache_path}/oembed_cache.pstore"
  
  begin
    db = PStore.new(cache_file)
    db.transaction do |store|
      cached = store[:responses][url] unless store[:responses].nil?
      if cached && cached[:expires_at] && Time.now < cached[:expires_at]
        return build_html(cached[:json], url)
      end
    end
      
    # サービスのoEmbedエンドポイントをcacheまたはHTMLから探す
    endpoint = get_oembed_endpoint(url, db)
    return fallback_html(url) unless endpoint
    
    # oEmbedによる埋め込みコードの取得
    oembed_data = fetch_oembed(endpoint, url, width, height)
    return fallback_html(url) unless oembed_data
      
    db.transaction do |store|
      store[:responses] ||= {}
      store[:responses][url] = {
        json: oembed_data,
        expires_at: Time.now + (3600 * 24 * 3)
      }
    end
      build_html(oembed_data, url)
  rescue => e
    fallback_html(url)
  end
end
