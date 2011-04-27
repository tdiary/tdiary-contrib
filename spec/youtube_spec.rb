$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe "youtube plugin" do
	DUMMY_YOUTUBE_VIDEO_ID = 1234567890

  {
    'DoCoMo' => %|<div class="youtube"><a href="http://www.youtube.com/watch?v=#{DUMMY_YOUTUBE_VIDEO_ID}">YouTube (#{DUMMY_YOUTUBE_VIDEO_ID})</a></div>|,
    'iPhone' => %|\t\t<iframe class="youtube-player" type="text/html" width="240" height="194" src="http://www.youtube.com/embed/#{DUMMY_YOUTUBE_VIDEO_ID}" frameborder="0">\n\t\t</iframe>\n\t\t<div class="youtube"><a href="http://www.youtube.com/watch?v=#{DUMMY_YOUTUBE_VIDEO_ID}">YouTube (#{DUMMY_YOUTUBE_VIDEO_ID})</a></div>\n|,
    'Mozilla' => %|\t\t<iframe class="youtube-player" type="text/html" width="425" height="350" src="http://www.youtube.com/embed/#{DUMMY_YOUTUBE_VIDEO_ID}" frameborder="0">\n\t\t</iframe>\n|
  }.each do |k,v|
    it 'should render object tag in :user_agent' do
      plugin = fake_plugin(:youtube)
      cgi = CGIFake.new
      cgi.user_agent = k
      plugin.conf.cgi = cgi
      plugin.youtube(DUMMY_YOUTUBE_VIDEO_ID).should == v
    end
  end
end
