#
# antirefspamfilter.rb
#
# Copyright (c) 2004-2005 T.Shimomura <redbug@netlife.gr.jp>
# You can redistribute it and/or modify it under GPL2.
# Please use version 1.0.0 (not 1.0.0G) if GPL doesn't want to be forced on me.
#

require 'net/http'
require 'uri'

module TDiary
  module Filter

    class AntirefspamFilter < Filter
      # 有効にすると指定したファイルにデバッグ情報文字列を追記する
      def debug_out(filename, str)
        if $debug
          filename = File.join(@conf.data_path,"AntiRefSpamFilter",filename)
          File::open(filename, "a+") {|f|
            f.puts str
          }
        end
      end

      # str に指定された文字列が適切なリンク先を含んでいるかをチェック
      def isIncludeMyUrl(str)
        # str に日記のURLが含まれているかどうか
        base_url = @conf.base_url
        unless base_url.empty?
          if str.include? base_url
            return true
          end
        end

        # str にトップページURLが含まれているかどうか
        unless @conf.index_page.empty?
          if /\Ahttps?:\/\// =~ @conf.index_page
            if str.include? @conf.index_page
              return true
            end
          end
        end

        # str に許容するリンク先が含まれているかどうか
        if (myurl = @conf['antirefspam.myurl']) && !myurl.empty?
          if str.include? myurl
            return true
          end
          
          url = myurl.gsub("/", "\\/").gsub(":", "\\:")
          exp = Regexp.new(url)
          if exp =~ str
            return true
          end
        end

        return false
      end

      def referer_filter(referer)
        conf_disable = @conf['antirefspam.disable'] != nil ? @conf['antirefspam.disable'].to_s : ''
        conf_checkreftable = @conf['antirefspam.checkreftable'] != nil ? @conf['antirefspam.checkreftable'].to_s : ''
        conf_trustedurl = @conf['antirefspam.trustedurl'] != nil ? @conf['antirefspam.trustedurl'].to_s : ''
        conf_proxy_server = @conf['antirefspam.proxy_server'] != nil && @conf['antirefspam.proxy_server'].size > 0 ? @conf['antirefspam.proxy_server'].to_s : nil
        conf_proxy_port = @conf['antirefspam.proxy_port'] != nil && @conf['antirefspam.proxy_port'].size > 0 ? @conf['antirefspam.proxy_port'].to_s : nil

        if conf_disable == 'true'  or    # リンク元チェックが有効ではない場合はスルーする
           referer == nil          or    # リンク元が無い
           referer.size <= 1       or    # 一部のアンテナで更新時刻が取れなくなる問題に対応するため、リンク元が１文字以内の場合は許容
           isIncludeMyUrl(referer)       # 自分の日記内からのリンクは信頼する
        then
          return true
        end

        # "信頼できるURL" を１つずつ取り出してrefererと合致するかチェックする
        conf_trustedurl.each_line do |trusted|
          trusted.sub!(/\r?\n/,'')
          next if trusted =~ /\A(\#|\s*)\z/  # #または空白で始まる行は読み飛ばす
          
          # まずは "信頼できる URL" が referer に含まれるかどうか
          if referer.include? trusted
            debug_out("trusted", trusted+" (include?) "+referer)
            return true
          end
          
          # 含まれなかった場合は "信頼できる URL" を正規表現とみなして再チェック
          begin
            if referer =~ Regexp.new( trusted.gsub("/", "\\/").gsub(":", "\\:") )
              debug_out("trusted", trusted+" (=~) "+referer)
              return true
            end
          rescue
            debug_out("error_config", "trustedurl: "+trusted)
          end
        end

        # URL置換リストを見る
        if conf_checkreftable == 'true'
          # "URL置換リスト" を１つずつ取り出してrefererと合致するかチェックする
          @conf.referer_table.each do |url, name|
            begin
              if /#{url}/i =~ referer && url != '^(.{50}).*$'
                debug_out("trusted", url+" (=~referer_table)  "+referer)
                return true
              end
            rescue
              debug_out("error_config", "referer_table: "+url)
            end
          end
        end

        @work_path = File.join(@conf.data_path,"AntiRefSpamFilter")
        @spamurl_list = File.join(@work_path,"spamurls")  # referer spam のリンク元一覧
        @spamip_list  = File.join(@work_path,"spamips")   # referer spam のIP一覧
        @safeurl_list = File.join(@work_path,"safeurls")  # おそらくは問題のないリンク元一覧

        # ディレクトリ/ファイルが存在しなければ作る
        unless File.exist? @work_path
          Dir::mkdir(@work_path)
        end
        unless File.exist? @spamurl_list
          File::open(@spamurl_list, "a").close
        end
        unless File.exist? @safeurl_list
          File::open(@safeurl_list, "a").close
        end

        uri = URI.parse(referer)
        temp_filename = File.join(@work_path,uri.host)
        # チェック時には対象のドメイン名を持った一時ファイルを作る
        begin
          File::open(temp_filename, File::RDONLY | File::CREAT | File::EXCL).close

          # 一度 SPAM URL とみなしたら以後は以後は拒否
          spamurls = IO::readlines(@spamurl_list).map {|url| url.chomp }
          if spamurls.include? referer
            return false
          end

          # 一度 SPAM URL でないと判断したら以後は許可
          safeurls = IO::readlines(@safeurl_list).map {|url| url.chomp }
          if safeurls.include? referer
            return true
          end

          # リンク元 URL の HTML を引っ張ってくる
          Net::HTTP.version_1_2   # おまじないらしい
          body = ""
          begin
            Net::HTTP::Proxy(conf_proxy_server, conf_proxy_port).start(uri.host, uri.port) do |http|
              if uri.path == ""
                response, = http.get("/")
              else
                response, = http.get(uri.request_uri)
              end
              body = response.body
            end

            # body に日記の URL が含まれていなければ SPAM とみなす
            unless isIncludeMyUrl(body)
              File::open(@spamurl_list, "a+") {|f|
                f.puts referer
              }
              File::open(@spamip_list, "a+") {|f|
                f.puts [@cgi.remote_addr, Time.now.utc.strftime("%Y/%m/%d %H:%M:%S UTC")].join("\t")
              }
              return false
            else
              File::open(@safeurl_list, "a+") {|f|
                f.puts referer
              }
            end
          rescue
            # エラーが出た場合は @spamurl_list に入れない＆リンク元にも入れない
            return false
          end

        rescue StandardError, TimeoutError
          # 現在チェック中なら、今回はリンク元に勘定しない
          return false
        ensure
          begin
            File::delete(temp_filename)
          rescue
          end
        end

        return true
      end



      def log_spamcomment( diary, comment )
        @work_path = File.join(@conf.data_path,"AntiRefSpamFilter")
        @spamcomment_list = File.join(@work_path,"spamcomments")  # comment spam の一覧

        # ディレクトリ/ファイルが存在しなければ作る
        unless File.exist? @work_path
          Dir::mkdir(@work_path)
        end
        unless File.exist? @spamcomment_list
          File::open(@spamcomment_list, "a").close
        end

        File::open(@spamcomment_list, "a+") {|f|
          f.puts "From: "+comment.name+" <"+comment.mail+">"
          f.puts "To: "+diary.date.to_s
          f.puts "Date: "+comment.date.to_s
          f.puts comment.body
          f.puts ".\n\n"
        }
      end

      def comment_filter( diary, comment )
        # ツッコミに日本語(ひらがな/カタカナ)が含まれていなければ不許可
        if @conf['antirefspam.comment_kanaonly'] != nil
          if @conf['antirefspam.comment_kanaonly'].to_s == 'true'
            unless comment.body =~ /[ぁ-んァ-ヴー]/
              log_spamcomment( diary, comment )
              return false
            end
          end
        end

        # ツッコミの文字数が指定した上限以内でないなら不許可
        maxsize = @conf['antirefspam.comment_maxsize'].to_i
        if maxsize > 0
          unless comment.body.size <= maxsize
            log_spamcomment( comment )
            return false
          end
        end

        # NGワードが１つでも含まれていたら不許可
        if @conf['antirefspam.comment_ngwords'] != nil
          ngwords = @conf['antirefspam.comment_ngwords']
          ngwords.to_s.each_line do |ngword|
            ngword.sub!(/\r?\n/,'')
            if comment.body.downcase.include? ngword.downcase
              log_spamcomment( comment )
              return false
            end

            # 含まれなかった場合は "NGワード" を正規表現とみなして再チェック
            begin
              if comment.body =~ Regexp.new( ngword, Regexp::MULTILINE )
                log_spamcomment( comment )
                return false
              end
            rescue
              debug_out("error_config", "comment_ngwords: "+ngword)
            end
          end
        end

        return true
      end
    end
  end
end
