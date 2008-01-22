require 'tmpdir'
require 'fileutils'
begin
  require 'my_hotentry'
rescue
end

describe "MyHotEntry" do
	before do
		# @cache_path は「ファイル名-プロセス番号」
		@cache_path = File.join(Dir.tmpdir, "#{File.basename(__FILE__)}-#{$$}")
		Dir.mkdir(@cache_path)
		@dbfile = "#{@cache_path}/my_hotentry.dat"
	end

	after do
		FileUtils.rmtree(@cache_path)
	end

	it "update" do
		# 人気の日記一覧を取得する
		base_url = 'http://d.hatena.ne.jp/'
		hotentry = MyHotEntry.new(@dbfile)
		hotentry.update(base_url)
		# キャッシュファイルが生成されていること
		File.file?(@dbfile).should be_true
		# 人気の日記が取得できていること
		entries = hotentry.entries
		entries.size.should > 0
		entries.each do |entry|
			entry[:url].should be_include(base_url)
			entry[:title].size.should > 0
		end
	end

	# 何度も取得してもキャッシュサイズが大きくならないこと
	it "double update" do
		base_url = 'http://d.hatena.ne.jp/'
		hotentry = MyHotEntry.new(@dbfile)
		sleep 0.5
		hotentry.update(base_url)
		hotentry.entries.size.should > 0
		size = hotentry.entries.size
		sleep 0.5
		hotentry.update(base_url)
		hotentry.entries.size.should == size
	end

	# 取得結果が空の場合はキャッシュをクリアしない
	it "update noentry" do
		exist_url = 'http://d.hatena.ne.jp/'
		empty_url = 'http://empty-url-123456'
		hotentry = MyHotEntry.new(@dbfile)

		sleep 0.5
		hotentry.update(empty_url)
		hotentry.entries.size.should == 0

		sleep 0.5
		hotentry.update(exist_url)
		hotentry.entries.size.should > 0
		exist_size = hotentry.entries.size

		sleep 0.5
		hotentry.update(empty_url)
		hotentry.entries.size.should == exist_size
	end
end
