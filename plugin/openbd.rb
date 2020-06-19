# openbd.rb
#
# Copyright (C) 2020 OGAWA KenIchi <kenichi@ice.email.ne.jp>
# You can redistribute it and/or modify it under GPL2 or any later version.
#

require "net/http"
require "json"
require "uri"

module OpenBD
	class Item
		attr_reader :isbn

		def initialize(isbn, json)
			@isbn = isbn
			@data = JSON.parse(json)[0] || {}
		end

		def normalized_isbn
			nil_if_empty(@data.dig("summary", "isbn"))
		end

		def image_url
			nil_if_empty(@data.dig("summary", "cover"))
		end

		def title
			nil_if_empty(@data.dig("summary", "title"))
		end

		def author
			nil_if_empty(@data.dig("summary", "author"))
		end

		def title_and_author
			author ? "#{title}(#{author})" : title
		end

		def publisher
			nil_if_empty(@data.dig("summary", "publisher"))
		end

		def price
			price = @data.dig("onix", "ProductSupply", "SupplyDetail", "Price", 0)
			return nil unless price
			value = price["PriceAmount"]
			currency_code = price["CurrencyCode"]
			case currency_code
			when "JPY"
				"#{value}円"
			else
				"#{currency_code} #{value}"
			end
		end

		private def nil_if_empty(s)
			s&.empty? ? nil : s
		end
	end

	class Cache
		def initialize(cache_path)
			@dir = File.join(cache_path, "openbd")
		end

		def load(isbn)
			File.read(path_for(isbn))
		rescue Errno::ENOENT
			nil
		end

		def save(isbn, json)
			Dir.mkdir(@dir) unless File.directory?(@dir)
			File.write(path_for(isbn), json)
		end

		def clear
			Dir.glob("#{@dir}/*").each { |f| File.delete(f) }
		end

		private def path_for(isbn)
			File.join(@dir, "#{isbn}.json")
		end
	end

	module_function

	def get_item(isbn, cache_path, mode)
		cache = OpenBD::Cache.new(cache_path)
		json = cache.load(isbn) if mode != "preview"
		unless json
			uri = URI("https://api.openbd.jp/v1/get?isbn=#{isbn}")
			response = Net::HTTP.get_response(uri)
			response.value # raise on errors
			json = response.body
			cache.save(isbn, json)
		end
		OpenBD::Item.new(isbn, json)
	end

	def reference_url(item)
		isbn13 = item.normalized_isbn
		if isbn13
			"https://www.hanmoto.com/bd/isbn/#{isbn13}"
		else
			"https://www.amazon.co.jp/dp/#{item.isbn}"
		end
	end

	def image_info(item, conf)
		width = conf["openbd.image_width"]
		height = conf["openbd.image_height"]
		url = item.image_url || conf["openbd.default_image"]
		if !url || url.empty?
			url = <<~EOS
				data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAMAAAAECAIAAADETxJQAAAAAXNSR0IArs4c6QAAAARnQU1BAACx
				jwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAXSURBVBhXYzx8+DADGDBBKCDAZDEwAABXngJR
				1c/tyAAAAABJRU5ErkJggg==
			EOS
			url.rstrip!
			width = 200 if !width && !height
		end
		{ url: url, width: width, height: height }
	end
end

def openbd_image(item, label, css_class)
	label ||= item.title_and_author || item.isbn
	href = OpenBD.reference_url(item)
	if @mode == "categoryview"
		img = ""
	else
		alt = ""
		if @conf["amazon.hidename"] || css_class != "amazon"
			label, alt = alt, label
		end
		image = OpenBD.image_info(item, @conf)
		width = image[:width]
		height = image[:height]
		img_width = width && %Q|width="#{h width}"|
		img_height = height && %Q|height="#{h height}"|
		img = <<~EOS
			<img class="#{h css_class}"
				src="#{h image[:url]}" #{img_width} #{img_height}
				alt="#{h alt}">
		EOS
	end
	%Q|<a href="#{h href}">#{img.rstrip}#{h label}</a>|
end

def openbd_process(isbn, &block)
	isbn = isbn.to_s.strip.gsub("-", "")
	block.call(OpenBD.get_item(isbn, @cache_path, @mode))
rescue => e
	@logger.error "openbd.rb: isbn=#{isbn}, message=#{e.message}"
	message = "[openBD plugin error]"
	if @mode == "preview"
		message << %Q|<span class="message">(#{h e.message})</span>|
	end
	message
end

def isbn_image(isbn, label = nil )
	openbd_process(isbn) do |item|
		openbd_image(item, label, "amazon")
	end
end

def isbn_image_left(isbn, label = nil)
	openbd_process(isbn) do |item|
		openbd_image(item, label, "left")
	end
end

def isbn_image_right(isbn, label = nil)
	openbd_process(isbn) do |item|
		openbd_image(item, label, "right")
	end
end

def isbn(isbn, label = nil)
	openbd_process(isbn) do |item|
		label ||= item.title_and_author || item.isbn
		%Q|<a href="#{h OpenBD.reference_url(item)}">#{h label}</a>|
	end
end

def isbn_detail(isbn)
	openbd_process(isbn) do |item|
		image = OpenBD.image_info(item, @conf)
		url = OpenBD.reference_url(item)
		<<-EOS
			<a class="amazon-detail" href="#{h url}"><span class="amazon-detail">
				<img class="amazon-detail left" src="#{h image[:url]}" alt="" height="75">
				<span class="amazon-detail-desc">
					<span class="amazon-title">#{h item.title}</span><br>
					<span class="amazon-author">#{h item.author || "-"}</span><br>
					<span class="amazon-label">#{h item.publisher || "-"}</span><br>
					<span class="amazon-price">#{h item.price || "-"}</span>
				</span>
			</span></a>
		EOS
	end
end

# for compatibility
alias isbnImgLeft isbn_image_left
alias isbnImgRight isbn_image_right
alias isbnImg isbn_image
alias amazon isbn_image

add_conf_proc("openbd", "openBD") do
	if @mode == "saveconf" then
		@conf["amazon.hidename"] = (@cgi.params["openbd.hidename"][0] == "true")
		@conf["openbd.default_image"] = @cgi.params["openbd.default_image"][0]

		to_px = lambda do |v|
			i = v.to_i
			i > 0 ? i : nil
		end
		@conf["openbd.image_width"] =
			to_px[@cgi.params["openbd.image_width"][0]]
		@conf["openbd.image_height"] =
			to_px[@cgi.params["openbd.image_height"][0]]

		if @cgi.params["openbd.clearcache"][0] == "true"
			OpenBD::Cache.new(@cache_path).clear
		end
	end

	hidename = @conf["amazon.hidename"]
	<<-EOS
		<h3>#{h @openbd_label_title}</h3>
		<p><select name="openbd.hidename">
			<option value="true"#{" selected" if hidename}>
				#{h @openbd_label_title_hide}
			</option>
			<option value="false"#{" selected" unless hidename}>
				#{h @openbd_label_title_show}
			</option>
		</select></p>

		<h3>#{h @openbd_label_clearcache}</h3>
		<p><label for="openbd.clearcache">
			<input type="checkbox" id="openbd.clearcache" name="openbd.clearcache" value="true">
			#{h @openbd_label_clearcache_desc}
		</label></p>

		<h3>#{h @openbd_label_default_image}</h3>
		<p>#{h @openbd_label_default_image_desc}</p>
		<p><input type="text" name="openbd.default_image" value="#{h @conf["openbd.default_image"]}" size="70"></p>

		<h3>#{h @openbd_label_image_width}</h3>
		<p>#{h @openbd_label_image_width_desc}</p>
		<p>
			<input type="text" name="openbd.image_width" value="#{h @conf["openbd.image_width"]}" size="5">
			<label for="openbd.image_width">px</label>
		</p>

		<h3>#{h @openbd_label_image_height}</h3>
		<p>#{h @openbd_label_image_height_desc}</p>
		<p>
			<input type="text" name="openbd.image_height" value="#{h @conf["openbd.image_height"]}" size="5">
			<label for="openbd.image_height">px</label>
		</p>
	EOS
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
