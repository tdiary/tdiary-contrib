$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe "google_video plugin" do
	def expected_html_snippet(options)
		doc_id = options[:doc_id]
		w = options[:width]
		h = options[:height]
		<<-EXPECTED
   <object class="googlevideo" width="#{w}" height="#{h}"><param name="movie" value="http://video.google.com/googleplayer.swf?docId=#{doc_id}&hl=en"></param
   ><embed src="http://video.google.com/googleplayer.swf?docId=#{doc_id}&hl=en" type="application/x-shockwave-flash" width="#{w}" height="#{h}"
   ></embed></object>
		EXPECTED
	end

	DUMMY_VIDEO_ID = 1234567890

	before do
		@plugin = fake_plugin(:google_video)
	end

	it "should render 425x320 object tag" do
		snippet = @plugin.google_video(DUMMY_VIDEO_ID)
		snippet.should == expected_html_snippet(
			:doc_id => DUMMY_VIDEO_ID,
			:width => 425, :height => 320)
	end

	it "should render 212x160 object tag" do
		snippet = @plugin.google_video(DUMMY_VIDEO_ID, "212x160")
		snippet.should == expected_html_snippet(
			:doc_id => DUMMY_VIDEO_ID,
			:width => 212, :height => 160)
	end
end
