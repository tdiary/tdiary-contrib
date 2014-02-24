# -*- coding: utf-8 -*-

require 'spec_helper'
require 'profile'

describe "Profile::Service" do
  describe "GitHub" do
    before do
      require 'json'
      allow_any_instance_of(Profile::Service::GitHub).to receive(:fetch).and_return(JSON.parse(File.read("spec/fixtures/github.json")))

      # workaround for run spec on various environment.
      require 'openssl'
      OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

      # http://develop.github.com/p/general.html
      @profile = Profile::Service::GitHub.new("schacon", :size => 40)
    end

    it "should include name, mail, image properties" do
      expect(@profile.name).to eq("Scott Chacon")
      expect(@profile.mail).to eq("schacon@gmail.com")
      expect(@profile.image).to eq("http://www.gravatar.com/avatar/9375a9529679f1b42b567a640d775e7d.jpg?s=40")
    end
  end

  describe "Twitter" do
    before do
      allow_any_instance_of(Profile::Service::Twitter).to receive(:fetch).and_return(REXML::Document.new(File.read("spec/fixtures/twitter.xml")))

      # http://twitter.com/tdiary
      @profile = Profile::Service::Twitter.new("tdiary")
    end

    it "should include name, description, image properties" do
      expect(@profile.name).to eq("tDiary.org")
      expect(@profile.description).to eq("tDiaryオフィシャルアカウント")
      expect(@profile.image).to match(%r{^http://.*\.(png|jpg)$})
    end
  end

  describe "FriendFeed" do
    before do
      allow_any_instance_of(Profile::Service::FriendFeed).to receive(:fetch).and_return(REXML::Document.new(File.read("spec/fixtures/friendfeed.xml")))

      # http://friendfeed.com/api/documentation#summary
      @profile = Profile::Service::FriendFeed.new("bret")
    end

    it "should include name, description, image properties" do
      expect(@profile.name).to eq("Bret Taylor")
      expect(@profile.description).to eq("Ex-CTO of Facebook. Previously co-founder and CEO of FriendFeed. Programmer, food lover.")
      expect(@profile.image).to eq("http://friendfeed-api.com/v2/picture/bret")
    end
  end

  describe "Gravatar" do
    # http://ja.gravatar.com/site/implement/url

    before do
      @profile = Profile::Service::Gravatar.new("iHaveAn@email.com")
    end

    it "should include image property" do
      expect(@profile.image).to eq("http://www.gravatar.com/avatar/3b3be63a4c2a439b013787725dfce802.jpg")
    end

    context 'with options' do
      before do
        @profile = Profile::Service::Gravatar.new("iHaveAn@email.com", :size => 40)
      end

      it "should specify size option" do
        expect(@profile.image).to eq("http://www.gravatar.com/avatar/3b3be63a4c2a439b013787725dfce802.jpg?s=40")
      end
    end
  end

  describe "Hatena" do
    before do
      @profile = Profile::Service::Hatena.new("kmachu")
    end

    it "should include image property" do
      expect(@profile.image).to eq("http://www.hatena.ne.jp/users/km/kmachu/profile.gif")
    end
  end
end
