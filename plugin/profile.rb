#
# profile.rb: profile plugin for tDiary
#
# usage:
#   profile(id[, service = :twitter])
#   - id: user ID for profile service
#   - service: profile service (default is :twitter)
#     Choose from :github, :twitter, :friendfeed, :iddy
#
# Copyright (C) 2009 by MATSUOKA Kohei < http://www.machu.jp/ >
# Distributed under the GPL.
#
require 'timeout'
require 'rexml/document'
require 'open-uri'
require 'digest/md5'
require 'pstore'

module ::Profile
  module Service
    # abstract class for profile services
    class Base
      attr_reader :id
      attr_reader :image
      attr_reader :name
      attr_reader :mail
      attr_reader :description
      attr_reader :link
    end

    # github.com
    class GitHub < Base
      def initialize(id, options = {})
        @id = id
        req = "http://github.com/api/v2/xml/user/show/#{id}"
        timeout(5) do
          open(req){|f| parse_profile(f) }
        end
      end

      # parse profile XML
      def parse_profile(f)
        doc = REXML::Document.new(f)
        @name = doc.elements['//user/name'].text if doc.elements['//user/name']
        @mail = doc.elements['//user/email'].text if doc.elements['//user/email']
        # github uses gravater.com for user icon
        @image = "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(@mail)}.jpg"
      end

      # link for your profile service
      def link
        "http://github.com/#{@id}"
      end
    end

    # twitter.com
    class Twitter < Base
      def initialize(id, options = {})
        @id = id
        req = "http://twitter.com/users/show/#{id}.xml"
        timeout(5) do
          open(req){|f| parse_profile(f) }
        end
      end

      # parse profile XML
      def parse_profile(f)
        doc = REXML::Document.new(f)
        @name = doc.elements['//user/name'].text if doc.elements['//user/name']
        @image = doc.elements['//user/profile_image_url'].text if doc.elements['//user/profile_image_url']
        @description = doc.elements['//user/description'].text if doc.elements['//user/description']
      end

      # link for your profile service
      def link
        "http://twitter.com/#{@id}"
      end
    end

    # friendfeed.com
    class FriendFeed < Base
      def initialize(id, options = {})
        @id = id
        req = "http://friendfeed-api.com/v2/feed/#{id}"
        req << "?format=xml&num=0"
        timeout(5) do
          open(req){|f| parse_profile(f) }
        end
      end

      # parse profile XML
      def parse_profile(f)
        doc = REXML::Document.new(f)
        @name = doc.elements['//feed/name'].text if doc.elements['//feed/name']
        @image = "http://friendfeed-api.com/v2/picture/#{id}"
        @description = doc.elements['//feed/description'].text if doc.elements['//feed/description']
      end

      # link for your profile service
      def link
        "http://friendfeed.com/#{@id}"
      end
    end

    # iddy.jp
    # this class is based on iddy.rb
    class Iddy < Base
      ######################################################################
      # If you will modify or release another version of this code,
      # please get your own application key from iddy.jp and replace below.
      ######################################################################
      API_KEY = '9262ea8ffba962aabb4f1a1d3f1cfa953b11aa23'

      def initialize(id, options = {})
        @id = id
        req = "http://iddy.jp/api/user/?apikey=#{API_KEY}"
        req << "&accountname=#{id}"
        timeout(5) do
          open(req){|f| parse_profile(f) }
        end
      end

      # parse profile XML
      def parse_profile(f)
        doc = REXML::Document.new(f)
        @name = doc.elements['//response/users/user/name'].text
        @image = doc.elements['//response/users/user/imageurl'].text
        @description = doc.elements['//response/users/user/profile'].text
      end

      # link for your profile service
      def link
        "http://iddy.jp/profile/#{@id}/"
      end
    end

  end
end

def profile(id, service = :twitter)
  # FIXME: move to user stylesheet
  html = <<-EOS
  <style type="text/css">
    div.profile {
      margin: 1em;
      text-align: center;
      border: solid 1px #999;
    }
    div.profile img {
      border: none;
    }
    div.profile span {
      font-size: 0.9em;
      display: block;
    }
  </style>
  EOS

  service_class = {
    :twitter => Profile::Service::Twitter,
    :github => Profile::Service::GitHub,
    :friendfeed => Profile::Service::FriendFeed,
    :iddy => Profile::Service::Iddy,
  }[service.to_s.downcase.to_sym]

  cache = "#{@cache_path}/profile.pstore"
  profile = nil
  db = PStore.new(cache)
  db.transaction do
    key = service_class.name
    db[key] ||= {} # initialize db
    updated = db[key][:updated]
    if updated && (Time::now < updated + 60 * 60)
      # use cache
      profile = db[key][:profile]
    else
      # get latest date and update cache
      begin
        profile = service_class.new(id)
      rescue # Timeout::Error
        return html << %Q{ <div class="profile">no profile</div> }
      end
      db[key][:updated] = Time::now
      db[key][:profile] = profile
    end
  end

  html << %Q{ <div class="profile"><a href="#{CGI.escapeHTML profile.link}"> }
  html << %Q{ <span class="profile-image"><img src="#{CGI.escapeHTML profile.image}"></span> } if profile.image
  html << %Q{ <span class="profile-name">#{CGI.escapeHTML profile.name}</span> } if profile.name
  html << %Q{ <span class="profile-mail">#{CGI.escapeHTML profile.mail}</span> } if profile.mail
  html << %Q{ <span class="profile-description">#{CGI.escapeHTML profile.description}</span> } if profile.description
  html << %Q{ </a></div> }
end

# FIXME: for testing, please rewrite to RSPEC
if __FILE__ == $0
  $KCODE = 'u'
  require 'cgi'
  @cache_path = '.'
  p profile('machu', :iddy)
end
