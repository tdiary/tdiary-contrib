# Copyright (C) 2007, KURODA Hiraku <hiraku@hinet.mydns.jp>
# You can redistribute it and/or modify it under GPL2. 

class SpambayesConfig
	module Res
		module_function

		def title
			"Bayesフィルタ"
		end

		def check_comment
			"ツッコミを確認する"
		end

		def check_referer
			"リンク元を確認する"
		end

		def token_list(type)
			"#{type}トークン一覧"
		end

		def rebuild_db
			"データベースの再構築"
		end

		def use_bayes_filter
			"Bayesフィルタを使う"
		end

		def use_filter_to_referer
			"リンク元にBayesフィルタを使う"
		end

		def save_error_log
			"エラーログをキャッシュディレクトリに保存"
		end

		def threshold
			"閾値"
		end

		def receiver_addr
			"宛先メールアドレス"
		end

		def stay_ham
			"ハムのまま"
		end

		def register_ham
			"ハムとして登録"
		end

		def stay_spam
			"スパムのまま"
		end

		def register_spam
			"スパムとして登録"
		end

		def comment_processed
			"ツッコミを処理しました"
		end

		def token
			"トークン"
		end

		def probability(type)
			"#{type}率"
		end

		def score_in_db(type)
			"#{type}データベースでのスコア"
		end

		def execute_after_click_OK
			"OKを押すと実行します"
		end

		def registered_as(type)
			"#{type}として登録しました"
		end

		def rebuild_db_after_click_OK
			"OKを押すとコーパスからデータベースを再作成します"
		end

		def processed_referer
			"リンク元を処理しました"
		end

		def token_of_referer
			"リンク元のトークン"
		end

		def mail
			"メールアドレス"
		end

		def posted_host_addr
			"投稿ホストのIP"
		end

		def name
			"名前"
		end

		def referer
			"リンク元"
		end

		def url_in_comment
			"コメント中のURL"
		end

		def comment_body_and_keyword
			"コメント本文と検索リンク元のキーワード"
		end

		def no_token_exist
			"(トークンがありません)"
		end
	end
end
