# Copyright (C) 2008, KURODA Hiraku <hiraku@hinet.mydns.jp>
# You can redistribute it and/or modify it under GPL2.

require "bayes"
require "kconv"

module Bayes
	module CHARSET
		module EUC
			KCONV = Kconv::EUC
		end

		module UTF8
			KCONV = Kconv::UTF8
		end
	end

	class FilterBase
		def convert_corpus(corpus, to_code, from_code)
			r = self.class::Corpus.new
			corpus.each do |k, v|
				r[k.kconv(to_code::KCONV, from_code::KCONV)] = v
			end
			r
		end
		private :convert_corpus

		def convert(to_code, from_code)
			@charset = to_code
			@ham = convert_corpus(@ham, to_code, from_code)
			@spam = convert_corpus(@spam, to_code, from_code)
		end
	end
end
