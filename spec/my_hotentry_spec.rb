# -*- coding: utf-8 -*-

$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe "MyHotEntry" do
	def cache_filename
		"#{File.basename(__FILE__, ".rb")}-#{$$}"
	end
	before(:each) do
		stub_request(:get, "http://b.hatena.ne.jp/entrylist?mode=rss&url=http%3A%2F%2Fd.hatena.ne.jp%2F&sort=eid&threshold=3")
			.to_return(status: 200, body: File.new('spec/fixtures/my_hotentry/entrylist.xml'))
		stub_request(:get, "http://b.hatena.ne.jp/entrylist?mode=rss&sort=eid&threshold=3&url=http://empty-url.example.com/")
			.to_return(status: 200, body: File.new('spec/fixtures/my_hotentry/entrylist-empty.xml'))

		fake_plugin(:my_hotentry)
		@cache_path = File.join(Dir.tmpdir, cache_filename)
		Dir.mkdir(@cache_path)
		@dbfile = "#{@cache_path}/my_hotentry.dat"
		@base_url = 'http://d.hatena.ne.jp/'
		@hotentry = MyHotEntry.new(@dbfile)
	end

	after(:each) do
		FileUtils.rmtree(@cache_path)
	end

	describe "#update" do
		before do
			@hotentry.update(@base_url)
			@entries = @hotentry.entries
		end

		it "キャッシュファイルが生成されていること" do
			expect(File).to be_file(@dbfile)
		end

		it "人気の日記が取得できていること" do
			expect(@entries.size).to be > 0
		end

		it "取得したエントリにbase_urlとタイトルが含まれていること" do
			@entries.each do |entry|
				expect(entry[:url]).to be_include(@base_url)
				expect(entry[:title].size).to be > 0
			end
		end
	end

	describe "何度もupdateした場合" do
		before do
			@hotentry.update(@base_url)
			@original_entry_size = @hotentry.entries.size
			@hotentry.update(@base_url)
			@entry_size = @hotentry.entries.size
		end

		it "キャッシュサイズが大きくならないこと" do
			expect(@entry_size).to eq(@original_entry_size)
		end
	end

	describe "取得結果が空の場合" do
		before do
			@exist_url = 'http://d.hatena.ne.jp/'
			@empty_url = 'http://empty-url.example.com/'
		end

		it "キャッシュをクリアしないこと" do
			@hotentry.update(@empty_url)
			expect(@hotentry.entries.size).to eq(0)

			@hotentry.update(@exist_url)
			expect(@hotentry.entries.size).to be > 0
			exist_size = @hotentry.entries.size

			@hotentry.update(@empty_url)
			expect(@hotentry.entries.size).to eq(exist_size)
		end
	end
end
