# hide old diaries
#
# options configurable through settings:
#   @conf['volatile.limit'] : number of diaries to show
#
# Copyright (c) MATSUOKA Kohei <http://www.machu.jp/diary/>
# Distributed under the GPL
#
module ::TDiary
  # 複数の日記を一括して更新するためのクラス
  class TDiaryBulkUpdate < TDiaryUpdate
    def initialize( cgi, rhtm, conf )
      super
      date = Time::local( *cgi.params['date'][0].scan( /^(\d{4})(\d\d)$/ )[0] )
      @io.transaction( date ) do |diaries|
        yield(diaries)
        # DIRTY_DIARYは@ioへ日記を更新することを伝えるフラグ
        DIRTY_DIARY
      end
    end
  end
end

# 古い日記を非表示にするプラグイン
class VolatileDiaryPlugin
  def initialize(conf)
    @conf = conf
    @limit = conf['volatile.limit'] || 10
  end

  # all を true にすると全ての日記を対象とする
  def update(years, all = false)
    each_recent_diary(years) do |date, diary, count|
      diary.show(count <= @limit)
      all || count <= @limit
    end
  end

  def each_recent_diary(years)
    cgi = CGI.new
    count = 1
    break_flag = false
    years.keys.sort.reverse_each do |year|
      years[year].sort.reverse_each do |month|
        cgi.params['date'] = ["#{year}#{month}"]
        cgi.params['year'] = [year]
        cgi.params['month'] = [month]
        cgi.params['day'] = ["1"]
        m = TDiaryBulkUpdate::new(cgi, '', @conf) {|diaries|
          # diaries.class is Hash (date => diary)
          diaries.sort.reverse_each do |date, diary|
            unless yield(date, diary, count)
              break_flag = true
              break
            end
            count += 1
          end
        }
        break if break_flag
      end
      break if break_flag
    end
  end
end

add_update_proc do
  # 古い日記を非表示にする
  plugin = VolatileDiaryPlugin.new(@conf)
  plugin.update(@years)
end

add_conf_proc('volatile', "揮発性日記", 'update') do
  if @mode == 'saveconf' then
    @conf['volatile.limit'] = @cgi.params['volatile.limit'][0].to_i
    p = VolatileDiaryPlugin.new(@conf)
    p.update(@years, true)
  end

  r = <<-HTML
    <p>日記の更新時に古い日記を非表示にします。</p>
    <h3>公開する日記の件数</h3>
    <dl>
      <dt>公開したい日記の件数を入力してください。</dt>
      <dd><input name="volatile.limit" value="#{@conf['volatile.limit'] || '10'}"></dd>
    </dl>
  HTML
  r
end

