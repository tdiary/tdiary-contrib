$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe "flickr plugin" do
	let(:plugin) { fake_plugin(:flickr) }

	before(:all) do
		stub_request(:get, "https://www.flickr.com/services/rest/?api_key=f7e7fb8cc34e52db3e5af5e1727d0c0b&method=flickr.photos.getInfo&photo_id=5950109223")
				.to_return(status: 200, body: File.new('spec/fixtures/flickr/5950109223.flickr.photos.getInfo.xml'))
		stub_request(:get, "https://www.flickr.com/services/rest/?api_key=f7e7fb8cc34e52db3e5af5e1727d0c0b&method=flickr.photos.getSizes&photo_id=5950109223")
				.to_return(status: 200, body: File.new('spec/fixtures/flickr/5950109223.flickr.photos.getSizes.xml'))
	end

	describe '#flickr' do
		subject { plugin.flickr('5950109223', size = nil) }

		it do
			expect(subject).to eq %Q|<a href=\"https://www.flickr.com/photos/machu/5950109223/\" class=\"flickr\"><img title=\"RubyKaigi 2011\" alt=\"RubyKaigi 2011\" src=\"https://farm7.staticflickr.com/6006/5950109223_040097db92.jpg\" class=\"flickr photo\"></a>|
		end
	end
end
