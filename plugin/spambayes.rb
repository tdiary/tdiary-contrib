# Copyright (C) 2007, KURODA Hiraku <hiraku@hinet.mydns.jp>
# You can redistribute it and/or modify it under GPL2. 

require "bayes"

add_conf_proc("spambayes", SpambayesConfig::Res.title, "security") do
	spambayes_conf_proc
end

def spambayes_conf_proc
	SpambayesConfig.new(@mode, @cgi, @conf).show
end

module ::TDiary
	module Filter
		class Filter; end
		class SpambayesFilter < Filter
			class Comment; end
			class Referer; end
		end
	end
end

class SpambayesConfig
	Comment = ::TDiary::Filter::SpambayesFilter::Comment
	Referer = ::TDiary::Filter::SpambayesFilter::Referer

	RE_FILENAME_BODY = /\d+[a-z0-9]+/
	RE_SPAM_FILE = /^S#{RE_FILENAME_BODY}$/o
	RE_HAM_FILE = /^H#{RE_FILENAME_BODY}$/o
	RE_DOUBT_FILE = /^D#{RE_FILENAME_BODY}$/o
	RE_FILENAME = /^[SHD]#{RE_FILENAME_BODY}$/o

	def initialize(mode, cgi, conf)
		@mode = mode
		@cgi = cgi
		@conf = conf
		filter_path = conf.filter_path || "#{PATH}/tdiary/filter"
		require "#{filter_path}/spambayes"

		extend ::TDiary::Filter::SpambayesFilter::Misc
		::TDiary::Filter::SpambayesFilter::Misc.conf = conf
	end

	def save_mode?
		@mode=="saveconf"
	end

	def add_spam(data)
		t = data.token
		return if t.empty?
		bayes_filter.spam << t if t.any?{|i| !bayes_filter.spam.include?(i)}
		bayes_filter.spam << t while (bayes_filter.estimate(t)||0.0) <= threshold
		@db_updated = true
	end

	def add_ham(data, with_add_comment=false)
		t = data.token
		return if t.empty?
		bayes_filter.ham << t if t.any?{|i| !bayes_filter.ham.include?(i)}
		bayes_filter.ham << t while (bayes_filter.estimate(t)||1.0) > threshold
		@db_updated = true
		add_comment(data) if data.is_a?(Comment) && with_add_comment
	end

	def save_db
		bayes_filter.save if @db_updated
		@db_updated = false
	end

	def show
		case @cgi.params["sb_mode"][0]
		when "show_comment"
			show_all_comment
		when "process_comment"
			process_comment + show_config
		when "show_ham_tokens"
			show_db_token_list(:ham)
		when "show_spam_tokens"
			show_db_token_list(:spam)
		when "confirm_ham"
			confirm(:ham)
		when "confirm_spam"
			confirm(:spam)
		when "register_ham"
			register(:ham) + show_config
		when "register_spam"
			register(:spam) + show_config
		when "confirm_rebuild_db"
			confirm_rebuild_db
		when "rebuild_db"
			rebuild_db + show_config
		when "show_all_referer"
			show_all_referer
		when "process_referer"
			process_referer + show_config
		when "show_comment_token"
			show_comment_token
		when "show_referer_token"
			show_referer_token
		when "save_config"
			save_config + show_config
		else
			show_config
		end
	end

	def save_config
		return "" unless save_mode?
		r = ""
		@conf[conf_use] = @cgi.params[conf_use][0] || nil
		@conf[conf_for_referer] = @cgi.params[conf_for_referer][0] || nil
		@conf[conf_log] = @cgi.params[conf_log][0] || nil
		@conf[conf_mail] = @cgi.params[conf_mail][0] || nil
		@conf[conf_threshold] = @cgi.params[conf_threshold][0] || nil
		prm = @cgi.params[conf_filter][0] || "Plain"
		@conf[conf_filter] ||= "Plain"
		if @conf[conf_filter] != prm
			@conf[conf_filter] = prm
			rebuild_db
		end
		r
	end

	def show_config
		selected = "selected='selected'"
		@conf[conf_filter] ||= "Plain"
		<<EOT
<ul>
<li><a href="#{update_url}?conf=spambayes;sb_mode=show_comment">#{Res.check_comment}</a></li>
<li><a href="#{update_url}?conf=spambayes;sb_mode=show_all_referer">#{Res.check_referer}</a></li>
<li><a href="#{update_url}?conf=spambayes;sb_mode=show_spam_tokens">#{Res.token_list("SPAM")}</a></li>
<li><a href="#{update_url}?conf=spambayes;sb_mode=show_ham_tokens">#{Res.token_list("HAM")}</a></li>
<li><a href="#{update_url}?conf=spambayes;sb_mode=confirm_rebuild_db">#{Res.rebuild_db}</a></li>
</ul>
<hr>
<ul>
<li>#{Res.use_bayes_filter} : <input type='checkbox' name='#{conf_use}' #{@conf[conf_use] ? "checked='checked'" : ""}>
<li>#{Res.use_filter_to_referer} : <input type='checkbox' name='#{conf_for_referer}' #{@conf[conf_for_referer] ? "checked='checked'" : ""}>
<li>#{Res.save_error_log} : <input type='checkbox' name='#{conf_log}' #{@conf[conf_log] ? "checked='checked'" : ""}>
<li>#{Res.threshold} : <input type="text" name="#{conf_threshold}" value="#{threshold}"></li>
<li>#{Res.receiver_addr} : <input type="text" name="#{conf_mail}" value="#{@conf[conf_mail]}"></li>
<li><select name='#{conf_filter}'>
<option #{@conf[conf_filter]=="Plain" ? selected : ""}>Plain</option>
<option #{@conf[conf_filter]=="PaulGraham" ? selected : ""}>PaulGraham</option>
</select></li>
</ul>
<input type='hidden' name='sb_mode' value='save_config'>
EOT
	end

	def show_comment(data, name=nil, checked=nil)
		r = <<EOT
<a href='#{update_url}?edit=true;year=#{data.diary_date.year};month=#{data.diary_date.month};day=#{data.diary_date.day}'>
<span>#{data.name}(#{data.mail}) / #{data.date}</span>
</a>
<pre>#{CGI.escapeHTML(data.body)}</pre>
EOT
		rate = bayes_filter.estimate(data.token)
		r << "#{Res.spam_rate} : #{rate}" if rate
		if name
			sc = hc = ""
			case checked
			when :ham
				hc = "checked='checked'"
			when :spam
				sc = "checked='checked'"
			end
			r << <<EOT
<br>
<input type='radio' name='#{name}' value='ham' id='H#{name}' #{hc}>
<label for='H#{name}'>#{Res.stay_ham}</label><br>
<input type='radio' name='#{name}' value='spam' id='S#{name}' #{sc}>
<label for='S#{name}'>#{Res.register_spam}</label><br>
<a href='#{update_url}?conf=spambayes;sb_mode=show_comment_token;comment_id=#{name}'>token</a>
EOT
		end
		r
	end

	def show_all_comment
		r = ""
		spam_list = Dir["#{bayes_cache}/S*"].map{|i| File.basename(i)}.sort
		ham_list = Dir["#{bayes_cache}/H*"].map{|i| File.basename(i)}.sort
		doubt_list = Dir["#{bayes_cache}/D*"].map{|i| File.basename(i)}.sort
		r << "<h2>HAM</h2><ul>"
		ham_list.each do |f|
			data = Comment.load(data_file(f))
			r << "<li>\n#{show_comment(data, f, :ham)}\n</li>\n"
		end
		r << "</ul><h2>DOUBT</h2><ul>"
		doubt_list.each do |f|
			data = Comment.load(data_file(f))
			r << "<li>\n#{show_comment(data, f)}\n</li>\n"
		end
		r << "</ul><h2>SPAM</h2><ul>"
		spam_list.each do |f|
			data = Comment.load(data_file(f))
			r << "<li>\n#{show_comment(data, f, :spam)}\n</li>\n"
		end
		r << "</ul>"
		r << "<input type='hidden' name='conf' value='spambayes'>"
		r << "<input type='hidden' name='sb_mode' value='process_comment'>"
		r
	end

	def data_file(f)
		raise "InvalidData: #{CGI.escapeHTML(f)}" unless /^O?[SHD]\d+[a-z0-9]+$/ =~ f
		"#{bayes_cache}/#{f}"
	end

	def delete_data(f, type)
		require "fileutils"
		case type
		when :ham
			prefix = "H"
		when :spam
			prefix = "S"
		else
			prefix = "D"
		end
		if RE_FILENAME =~ f
			new_name = "#{corpus_path}/#{prefix}#{f[/^[SHD](#{RE_FILENAME_BODY})$/o, 1]}"
			FileUtils.mv(data_file(f), new_name)
		end
	end

	def process_comment
		return "" unless save_mode?
		@cgi.params.each do |k, v|
			next unless k=~/^[SHD]\d+[a-z0-9]+$/
			v = v[0]
			data = Comment.load(data_file(k))
			case k
			when RE_DOUBT_FILE
				case v
				when "spam"
					add_spam(data)
				when "ham"
					add_ham(data, true)
				else
					raise "INVALID VALUE"
				end
			when RE_SPAM_FILE
				if v=="ham"
					add_ham(data, true)
				end
			when RE_HAM_FILE
				if v=="spam"
					add_spam(data)
				end
			else
				raise "INVALID VALUE:#{k}"
			end
			delete_data(k, v=="spam" ? :spam : :ham)
		end
		save_db

		"<p>#{Res.comment_processed}</p><hr>"
	end

	def comment_date(data)
		data.diary_date.strftime("%Y%m%d")
	end

	def add_comment(data)
		comment = ::TDiary::Comment.new(data.name, data.mail, data.body, data.date)
		cgi = Struct.new(:params, :referer, :request_method, :remote_addr, :script_name).new("", "", "", "", "")
		cgi.params = Hash.new{[]}.update("name"=>[data.name], "mail"=>[data.mail], "body"=>[data.body], "date"=>[comment_date(data)])
		cgi.remote_addr = data.remote_addr
		io = force_filtering do
			@conf.io_class.new(::TDiary::TDiaryComment.new(cgi, "day.rhtml", @conf))
		end
		io.transaction(data.diary_date) do |diaries|
			diary = diaries[comment_date(data)]
			if diary
				without_filtering do
					diary.add_comment(comment)
				end
				::TDiary::TDiaryBase::DIRTY_COMMENT
			else
				::TDiary::TDiaryBase::DIRTY_NONE
			end
		end
	end

	def token_table(label, tokens, prefix)
		return "" if tokens.empty?
		r = "<h3>#{label}</h3>\n"
		r << "<table border='1'><tr><th>#{Res.token}</th><th>#{Res.probability("SPAM")}</th></tr>"
		bf = bayes_filter
		tokens = tokens.sort do |a, b|
			a=prefix+a
			b=prefix+b
			sa = bf.score(a) || 1.1
			sb = bf.score(b) || 1.1
			sa==sb ? a<=>b : sb<=>sa
		end
		tokens.each do |t|
			pt = prefix+t
			r << "<tr><th align='right'>#{t}</th><td>#{bf[pt] ? format("%10.4f", bf[pt]) : "Doubt"}</td></tr>\n"
		end
		r << "</table>"
	end

	def show_token_list(token_list)
		tl = {}
		token_list.uniq.each do |t|
			k = case t
			when /^A (.*)/
				:addr
			when /^M (.*)/
				:mail
			when /^N (.*)/
				:name
			when /^R (.*)/
				:referer
			when /^U (.*)/
				:url
			else
				:body
			end

			tl[k] ||= []
			tl[k] << ($1 ? $1 : t)
		end

		r = ""
		[[:body, Res.comment_body_and_keyword, ""],
			[:referer, Res.referer, "R "],
			[:url, Res.url_in_comment, "U "],
			[:name, Res.name, "N "],
			[:mail, Res.mail, "M "],
			[:addr, Res.posted_host_addr, "A "]].each do |i|
			key, label, prefix = i
			r << token_table(label, tl[key]||[], prefix)
		end
		if r.strip.empty?
			Res.no_token_exist
		else
			r
		end
	end

	def show_db_token_list(type)
		r = "<h2>#{Res.token_list(type.to_s.upcase)}</h2>"
		r << "<p>#{bayes_filter.class.name}</p>"

		show_token_list(bayes_filter.send(type).keys)
	end

	def confirm(type)
		r = "<h2>"
		id = @cgi.params["comment_id"][0]
		case type
		when :ham
			r << Res.register_ham
		when :spam
			r << Res.register_spam
		end
		r << "</h2>"
		r << "<input type='hidden' name='sb_mode' value='register_#{type.to_s}'>"
		r << "<input type='hidden' name='comment_id' value='#{id}'>"
		r << "<p><strong>#{Res.execute_after_click_OK}</strong></p>"
		r << "<hr>" << show_comment(Comment.load(data_file(id)))
	end

	def register(type)
		return "" unless save_mode?
		id = @cgi.params["comment_id"][0]
		data = Comment.load(data_file(id))
		r = ""
		case type
		when :ham
			add_ham(data, true)
			r << Res.registered_as(:HAM)
		when :spam
			add_spam(data)
			r << Res.registered_as(:SPAM)
		end
		save_db
		delete_data(id, type)
		r << show_comment(data) << "<hr>"
	end

	def confirm_rebuild_db
		<<EOT
<h2>#{Res.rebuild_db_after_click_OK}</h2>
<input type='hidden' name='sb_mode' value='rebuild_db'>
EOT
	end

	def rebuild_db
		return "NotSave" unless save_mode?

		bayes_filter(true).save

		r = ""

		spams = Dir["#{corpus_path}/S*"]
		hams = Dir["#{corpus_path}/H*"]
		all = []
		while spams.size>0 and hams.size>0
			all << spams.shift
			all << hams.shift
		end
		all.concat(spams)
		all.concat(hams)
		all.each do |f|
			n = f[/^#{Regexp.escape("#{corpus_path}/")}(.*)$/, 1]
			next unless RE_FILENAME =~ n
			data = Comment.load(f)
			case n[/^./]
			when "S"
				add_spam(data)
			when "H"
				add_ham(data)
			end
		end

		PStore.new(referer_corpus).transaction(true) do |db|
			(db["spam"]||[]).each do |ref|
				add_spam(ref)
			end
			(db["ham"]||[]).each do |ref|
				add_ham(ref)
			end
		end

		bayes_filter.save
		""
	end

	def show_referer_list(referer_list, type, ham_label, spam_label)
		h = "r"+type[0, 1]

		r = "<h3>#{type.upcase}</h3>\n"
		r << "<ul>\n"
		referer_list.uniq.sort.each do |l|
			r << "<li>#{l.viewable_html}<br>\n"
			r << "from #{l.remote_addr}<br>\n"
			rate = bayes_filter.estimate(l.token)
			r << "#{Res.spam_rate} : #{rate}<br>\n" if rate
			r << "<input type='radio' name='#{h}#{l.to_html}' id='H#{h}#{l.to_html}' value='ham'><label for='H#{h}#{l.to_html}'>#{ham_label}</label><br>\n"
			r << "<input type='radio' name='#{h}#{l.to_html}' id='S#{h}#{l.to_html}' value='spam'><label for='S#{h}#{l.to_html}'>#{spam_label}</label><br>\n"
			r << "<a href='#{update_url}?conf=spambayes;sb_mode=show_referer_token;referer=#{l.to_link}'>token</a>"
			r << "</li>"
		end
		r << "</ul>\n"
		r << "<input type='hidden' name='#{type[0, 1]}size' value='#{referer_list.size}'>\n"
	end

	def show_all_referer
		r = ""
		spams = Referer.load_list(referer_cache("spam"))
		hams = Referer.load_list(referer_cache("ham"))
		doubts = Referer.load_list(referer_cache("doubt"))

		r << show_referer_list(hams, "ham", Res.stay_ham, Res.register_spam)
		r << show_referer_list(spams, "spam", Res.register_ham, Res.stay_spam)
		r << show_referer_list(doubts, "doubt", Res.register_ham, Res.register_spam)
		r << "<input type='hidden' name='sb_mode' value='process_referer'>\n"
	end

	def process_referer
		return "" unless save_mode?
		spams = []
		hams = []
		processed = false
		@cgi.params.each do |k, v|
			next unless k=~/^r([shd])(.*)$/
			processed = true
			type = $1
			referer = Referer.from_html($2)
			v = v[0]
			case v
			when "spam"
				add_spam(referer) if type=~/^[dh]/
				spams << referer
			when "ham"
				add_ham(referer) if type=~/^[ds]/
				hams << referer
			end
		end
		if processed
			bayes_filter.save
			["ham", "spam", "doubt"].each do |k|
				size = (@cgi.params[k[0, 1]+"size"][0]||"0").to_i
				Referer.truncate_list(referer_cache(k), size)
			end

			PStore.new(referer_corpus).transaction do |db|
				spams.concat(db['spam']||[])
				hams.concat(db['ham']||[])
				db["spam"] = spams.uniq
				db["ham"] = hams.uniq
			end
		end

		"<p>#{Res.processed_referer}</p><hr>"
	end

	def show_comment_token
		c = Comment.load(data_file(@cgi.params["comment_id"][0]))
		show_token_list(c.token)
	end

	def show_referer_token
		ref = Referer.from_html(@cgi.params["referer"][0]||"")
		url = CGI.escapeHTML(ref.referer)
		"<a href='#{url}'>#{url}</a>"+show_token_list(ref.token)
	end
end
