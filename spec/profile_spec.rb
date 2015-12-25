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
      @profile = Profile::Service::GitHub.new("schacon")
    end

    it "should include name, mail, image properties" do
      expect(@profile.name).to eq("Scott Chacon")
      expect(@profile.mail).to eq("schacon@gmail.com")
      expect(@profile.image).to eq("https://avatars.githubusercontent.com/u/70?v=3")
    end
  end

  describe "Gravatar" do
    # http://ja.gravatar.com/site/implement/hash/

    before do
      require 'json'
      allow_any_instance_of(Profile::Service::Gravatar).to receive(:fetch).and_return(JSON.parse(File.read("spec/fixtures/gravatar.json")))

      @profile = Profile::Service::Gravatar.new("iHaveAn@email.com")
    end
    it "should include name, mail, image properties" do
      expect(@profile.name).to eq("tDiary")
      expect(@profile.mail).to eq("iHaveAn@email.com")
      expect(@profile.image).to eq("http://2.gravatar.com/avatar/3b3be63a4c2a439b013787725dfce802")
    end

    context 'with options' do
      before do
        @profile = Profile::Service::Gravatar.new("iHaveAn@email.com", :size => 40)
      end

      it "should specify size option" do
        expect(@profile.image).to eq("http://2.gravatar.com/avatar/3b3be63a4c2a439b013787725dfce802?s=40")
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
