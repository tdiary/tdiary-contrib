# Copyright (C) 2007, KURODA Hiraku <hiraku@hinet.mydns.jp>
# You can redistribute it and/or modify it under GPL2. 

class SpambayesConfig
	module Res
		module_function
		def title
			"Bayes filter"
		end

		def check_comment
			"Check comments"
		end

		def check_referer
			"Check referers"
		end

		def token_list(type)
			"#{type}-token list"
		end

		def rebuild_db
			"Rebuild database"
		end

		def use_bayes_filter
			"Use Bayes-filter"
		end

		def use_filter_to_referer
			"Use Bayes-filter to referer"
		end

		def save_error_log
			"Save error-log at cache-directory"
		end

		def threshold
			"Threshold"
		end

		def receiver_addr
			"Mail TO"
		end

		def stay_ham
			"Stay as HAM"
		end

		def register_ham
			"Register as HAM"
		end

		def stay_spam
			"Stay as SPAM"
		end

		def register_spam
			"Register as SPAM"
		end

		def comment_processed
			"Comments processed"
		end

		def token
			"token"
		end

		def probability(type)
			"#{type}-probability"
		end

		def score_in_db(type)
			"score in #{type}-database"
		end

		def execute_after_click_OK
			"Execute if you click OK"
		end

		def registered_as(type)
			"registered as #{type}"
		end

		def rebuild_db_after_click_OK
			"Rebuild database from corpus if you click OK"
		end

		def processed_referer
			"Referer processed"
		end

		def token_of_referer
			"token of referer"
		end

		def mail
			"Mail address"
		end

		def posted_host_addr
			"Host-IP from which comment posted"
		end

		def name
			"Name"
		end

		def referer
			"Referer"
		end

		def url_in_comment
			"URL in comment"
		end

		def comment_body_and_keyword
			"Text in comment and Keyword in search-engine's referer"
		end

		def no_token_exist
			"(No token exists)"
		end

		def spam_rate
			"SPAM rate"
		end
	end
end
