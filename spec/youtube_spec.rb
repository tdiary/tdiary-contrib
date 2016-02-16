$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe "youtube plugin" do
	DUMMY_YOUTUBE_VIDEO_ID = 1234567890

  {
    'Mozilla' => %|\t\t<div class="youtube-player-wrapper">\n\t\t<iframe class="youtube-player" type="text/html" width="425" height="350" src="//www.youtube.com/embed/#{DUMMY_YOUTUBE_VIDEO_ID}" frameborder="0">\n\t\t</iframe>\n\t\t</div>\n|
  }.each do |k,v|
    it 'should render object tag in :user_agent' do
      plugin = fake_plugin(:youtube)
      cgi = CGIFake.new
      cgi.user_agent = k
      plugin.conf.cgi = cgi
      expect(plugin.youtube(DUMMY_YOUTUBE_VIDEO_ID)).to eq(v)
    end
  end
end
