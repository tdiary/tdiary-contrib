$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe "youtube plugin" do
	DUMMY_YOUTUBE_VIDEO_ID = 1234567890

	before do
		@cgi = CGIFake.new
		@plugin = fake_plugin(:youtube)
	end

	it "should render object tag in mobile" do
		@cgi.user_agent = "DoCoMo"
		@plugin.conf.cgi = @cgi
		snippet = @plugin.youtube(DUMMY_YOUTUBE_VIDEO_ID)
		snippet.should == %Q|<div class="youtube"><a href="http://www.youtube.com/watch?v=#{DUMMY_YOUTUBE_VIDEO_ID}">YouTube (#{DUMMY_YOUTUBE_VIDEO_ID})</a></div>|
	end

	it "should render object tag in iPhone/iPod" do
		@cgi.user_agent = "iPhone"
		@plugin.conf.cgi = @cgi
		snippet = @plugin.youtube(DUMMY_YOUTUBE_VIDEO_ID)
		snippet.should == %Q|<div class="youtube"><a href="youtube:#{DUMMY_YOUTUBE_VIDEO_ID}">YouTube (#{DUMMY_YOUTUBE_VIDEO_ID})</a></div>|
	end

	it "should render object tag in webbrowser" do
		@cgi.user_agent = "Mozilla"
		@plugin.conf.cgi = @cgi
		snippet = @plugin.youtube(DUMMY_YOUTUBE_VIDEO_ID)
		snippet.should == <<-TAG
		<object width="425" height="350"><param name="movie" value="http://www.youtube.com/v/#{DUMMY_YOUTUBE_VIDEO_ID}"></param><embed src="http://www.youtube.com/v/#{DUMMY_YOUTUBE_VIDEO_ID}" type="application/x-shockwave-flash" width="425" height="350"></embed></object>
		TAG
	end
end
