$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe "github link plugin" do
	let(:plugin) { fake_plugin(:github_link) }
	subject { plugin.gh_link(arg) }

	describe 'repository page' do
		let(:arg) { 'tdiary/tdiary-contrib' }

		it 'should render repository a tag' do
			should == %(<a href='https://github.com/tdiary/tdiary-contrib'>tdiary-contrib</a>)
		end
	end

	describe 'issues page' do
		let(:arg) { 'tdiary/tdiary-contrib#100' }

		it 'should render issues a tag' do
			should == %(<a href='https://github.com/tdiary/tdiary-contrib/issues/100'>tdiary-contrib#100</a>)
		end
	end
end
