$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe "github link plugin" do
	let(:plugin) { fake_plugin(:github_link) }
	subject { plugin.gh_link(*args) }

	describe 'repository page' do
		let(:args) { ['tdiary/tdiary-contrib'] }

		it 'should render repository a tag' do
			is_expected.to eq(%(<a href='https://github.com/tdiary/tdiary-contrib'>tdiary-contrib</a>))
		end
	end

	describe 'issues page' do
		let(:args) { ['tdiary/tdiary-contrib#100'] }

		it 'should render issues a tag' do
			is_expected.to eq(%(<a href='https://github.com/tdiary/tdiary-contrib/issues/100'>tdiary-contrib#100</a>))
		end
	end
  context "When given altenative text" do
    let(:text) { 'This project' }
    let(:github_identifier) { 'tdiary/tdiary-contrib' }
    let(:args) { [github_identifier, text] }

		it 'should render repository a tag with the specified text' do
			is_expected.to eq(%(<a href='https://github.com/#{github_identifier}'>#{text}</a>))
		end
    context "but the text is including <script>" do
      let(:text) { '<script>alert("hoge");</script>' }

      it 'should render a link text after sanitizing.' do
        is_expected.not_to eq(%(<a href='https://github.com/#{github_identifier}'>#{text}</a>))
      end
    end
  end
end
