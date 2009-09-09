$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
require 'profile'

describe "Profile::Service" do

	describe "GitHub" do
		before :all do
      # http://develop.github.com/p/general.html
      @profile = Profile::Service::GitHub.new("schacon")
		end

    it "should include name, mail, image properties" do
      @profile.name.should == "Scott Chacon"
      @profile.mail.should == "schacon@gmail.com"
      @profile.image.should == "http://www.gravatar.com/avatar/9375a9529679f1b42b567a640d775e7d.jpg"
    end
	end

  describe "Twitter" do
    before :all do
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
    before :all do
      # http://friendfeed.com/api/documentation#summary
      @profile = Profile::Service::FriendFeed.new("bret")
    end

    it "should include name, description, image properties" do
      @profile.name.should == "Bret Taylor"
      @profile.description.should == "Co-founder of FriendFeed, programmer, food lover"
      @profile.image.should == "http://friendfeed-api.com/v2/picture/bret"
    end
  end

end
