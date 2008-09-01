#
# refererDbiIO.rb: load/save and show today's referer for DBI IO
# $Revision: 1.1 $
#
# Copyright        (C) 2003 ma2tak <ma2tak@ma2tak.dyndns.org>
#                  (C) 2004 moonwolf <moonwolf@mooonwolf.com>
#                  (C) 2005 Kazuhiko <kazuhiko@fdiary.net>
#                  (C) 2007 sasasin <sasasin@sasasin.net>
#
# You can distribute this under GPL.
#
def referer_transaction( diary = nil, save = false )
	return if @conf.io_class.to_s != 'TDiary::DbiIO'

	File.open("#{@conf.data_path}/dbi_io_ref.lock", 'w') {|file|
		file.flock(File::LOCK_EX)
		dbh = DBI.connect(@conf.dbi_driver_url, @conf.dbi_user, @conf.dbi_passwd)
		dbh.transaction{
			if diary.respond_to?( :date ) then
				table = 'refererdata'
				ymd = diary.date.strftime('%Y%m%d')
				begin
					sql = "SELECT diary_id, count, ref FROM " + table + " WHERE author=? AND diary_id=?;"
					dbh.select_all(sql, @conf.dbi_author || 'default', ymd) {|diary_id, count, ref|
						yield(ref.chomp, count.to_i)
					}
				rescue Errno::ENOENT
				end
			else
				table = 'referervolatile'
				ymd = nil
				begin
					sql = "SELECT diary_id, count, ref FROM " + table + " WHERE author=?;"
					dbh.select_all(sql, @conf.dbi_author || 'default') {|diary_id, count, ref|
						yield(ref.chomp, count.to_i)
						ymd = diary_id
					}
				rescue Errno::ENOENT
				end
			end

			if @mode =~ /^(append|replace)$/ and !diary.respond_to?( :date ) then
				if !ymd or (@date.strftime( '%Y%m%d' ) > ymd) then
					ymd = nil
					diary.clear_referers
					begin
						dbh.execute("TRUNCATE TABLE " + table + ";")
					rescue Errno::ENOENT
					end
					save = false
				end
			end

			if save then
				unless ymd then
					ymd = (@date ? @date : Time::now).strftime( '%Y%m%d' )
				end
				no = 0
				diary.each_referer(diary.count_referers) {|count,ref|
					no += 1
					param = [count, @conf.dbi_author, ymd, ref]
					begin
						sth = dbh.execute("UPDATE " + table + " SET count=? WHERE author=? AND diary_id=? AND ref=?;", *param)
						if sth.rows==0
							no = dbh.select_one("SELECT MAX(no) FROM " + table + " WHERE author=? AND diary_id=?", @conf.dbi_author, ymd).first.to_i + 1
							param << no
							dbh.execute("INSERT INTO " + table + " (count, author, diary_id, ref, no ) VALUES (?,?,?,?,?);", *param)
						end
					rescue DBI::ProgrammingError
						$stderr.puts "invalid referer:#{ref}"
					end
				}
			end
		}
	}
end
