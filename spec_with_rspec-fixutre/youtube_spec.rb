$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe "youtube plugin" do
	DUMMY_YOUTUBE_VIDEO_ID = 1234567890

  with_fixtures :user_agent => :expected do
    it 'should render object tag in :user_agent' do |user_agent, expected|
      cgi = CGIFake.new
      plugin = fake_plugin(:youtube)
      cgi.user_agent = user_agent
      plugin.conf.cgi = cgi
      plugin.youtube(DUMMY_YOUTUBE_VIDEO_ID).should == expected
    end

    set_fixtures([
      ['DoCoMo'  => 
          %|<div class="youtube"><a href="http://www.youtube.com/watch?v=#{DUMMY_YOUTUBE_VIDEO_ID}">YouTube (#{DUMMY_YOUTUBE_VIDEO_ID})</a></div>| 
      ],
      ['iPhone'  => 
          %|<div class="youtube"><a href="youtube:#{DUMMY_YOUTUBE_VIDEO_ID}">YouTube (#{DUMMY_YOUTUBE_VIDEO_ID})</a></div>|
      ],
      ["Mozilla" => 
          %|\t\t<object width="425" height="350"><param name="movie" value="http://www.youtube.com/v/#{DUMMY_YOUTUBE_VIDEO_ID}"></param><embed src="http://www.youtube.com/v/#{DUMMY_YOUTUBE_VIDEO_ID}" type="application/x-shockwave-flash" width="425" height="350"></embed></object>
|
      ],
    ])
  end
end

