$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe "gist plugin" do
	DUMMY_GIST_ID = 1234567890

	it 'should render javascript tag with specified gist-id' do
		plugin = fake_plugin(:gist)
		snippet = plugin.gist(DUMMY_GIST_ID)
		expected = (<<-EOS).chomp
<div class="gist_plugin"><script src="http://gist.github.com/1234567890.js"></script>
<noscript><a href="http://gist.github.com/1234567890">gist:1234567890</a></noscript></div>
		EOS
		snippet.should == expected
	end
end
