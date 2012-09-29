# -*- coding: utf-8 -*-

require 'spec_helper'
require 'profile'

describe "Profile::Service" do
  describe "GitHub" do
    before do
      require 'json'
      Profile::Service::GitHub.any_instance.stub(:fetch).and_return(JSON.parse(File.read("spec/fixtures/github.json")))

      # workaround for run spec on various environment.
      require 'openssl'
      OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

      # http://develop.github.com/p/general.html
      @profile = Profile::Service::GitHub.new("schacon", :size => 40)
    end

    it "should include name, mail, image properties" do
      @profile.name.should == "Scott Chacon"
      @profile.mail.should == "schacon@gmail.com"
      @profile.image.should == "http://www.gravatar.com/avatar/9375a9529679f1b42b567a640d775e7d.jpg?s=40"
    end
  end

  describe "Twitter" do
    before do
      Profile::Service::Twitter.any_instance.stub(:fetch).and_return(REXML::Document.new(File.read("spec/fixtures/twitter.xml")))

      # http://twitter.com/tdiary
      @profile = Profile::Service::Twitter.new("tdiary")
    end

    it "should include name, description, image properties" do
      @profile.name.should == "tDiary.org"
      @profile.description.should == "tDiaryオフィシャルアカウント"
      @profile.image.should match(%r{^http://.*\.(png|jpg)$})
    end
  end

  describe "FriendFeed" do
    before do
      Profile::Service::FriendFeed.any_instance.stub(:fetch).and_return(REXML::Document.new(File.read("spec/fixtures/friendfeed.xml")))

      # http://friendfeed.com/api/documentation#summary
      @profile = Profile::Service::FriendFeed.new("bret")
    end

    it "should include name, description, image properties" do
      @profile.name.should == "Bret Taylor"
      @profile.description.should == "Ex-CTO of Facebook. Previously co-founder and CEO of FriendFeed. Programmer, food lover."
      @profile.image.should == "http://friendfeed-api.com/v2/picture/bret"
    end
  end

  describe "Gravatar" do
    # http://ja.gravatar.com/site/implement/url

    before do
      @profile = Profile::Service::Gravatar.new("iHaveAn@email.com")
    end

    it "should include image property" do
      @profile.image.should == "http://www.gravatar.com/avatar/3b3be63a4c2a439b013787725dfce802.jpg"
    end

    context 'with options' do
      before do
        @profile = Profile::Service::Gravatar.new("iHaveAn@email.com", :size => 40)
      end

      it "should specify size option" do
        @profile.image.should == "http://www.gravatar.com/avatar/3b3be63a4c2a439b013787725dfce802.jpg?s=40"
      end
    end
  end

  describe "Hatena" do
    before do
      @profile = Profile::Service::Hatena.new("kmachu")
    end

    it "should include image property" do
      @profile.image.should == "http://www.hatena.ne.jp/users/km/kmachu/profile.gif"
    end
  end
end
