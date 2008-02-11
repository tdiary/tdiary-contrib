$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe "google_video plugin" do
	DUMMY_VIDEO_ID = 1234567890

  with_fixtures [:width, :height] => :expected do
    it 'should render :width x :height object tag' do |input, expected|
      plugin = fake_plugin(:google_video)
      snippet = plugin.google_video(DUMMY_VIDEO_ID, "#{input[:width]}x#{input[:height]}")
      snippet.should == expected
    end

    filters({
      :expected => lambda {|val|
        width, height = *val
        doc_id = DUMMY_VIDEO_ID

       %|<object class="googlevideo" width="#{width}" height="#{height}"><param name="movie" value="http://video.google.com/googleplayer.swf?docId=#{doc_id}&hl=en"></param><embed src="http://video.google.com/googleplayer.swf?docId=#{doc_id}&hl=en" type="application/x-shockwave-flash" width="#{width}" height="#{height}"></embed></object>|
      },
    })

    set_fixtures([
      [ [212, 160] => [212, 160] ],
      [ [425, 320] => [425, 320] ],
    ])
  end
end
