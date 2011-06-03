# -*- coding: utf-8 -*-
#
# search-google-custom.rb - site search plugin using Goole Custom Search.
#
# Copyright (C) 2011, hb <http://www.smallstyle.com>
# You can redistribute it and/or modify it under GPL.
#
# Needed these options below:
#
# @options["search-google-custom.id"] : Your Google Custome Search ID
#

def search_title
	'全文検索 by Google カスタム検索'
end

add_footer_proc do
		%Q|<script type="text/javascript" src="http://www.google.com/cse/brand?form=cse-search-box&lang=ja"></script>|
end

def search_input_form( q )
	r = <<-HTML
		<form action="#{@conf.index}" id="cse-search-box">
			<div>
				<input type="hidden" name="cx" value="#{@conf["search-google-custom.id"]}">
				<input type="hidden" name="cof" value="FORID:9">
				<input type="hidden" name="ie" value="UTF-8">
				<label for="q">検索キーワード:</label><input type="text" name="q" value="#{h q}">
				<input type="submit" name="sa" value="OK">
			</div>
		</form>
	HTML
end

def search_result
	r = <<-HTML
		<div id="cse-search-results"></div>
			<script type="text/javascript">
				var googleSearchIframeName = "cse-search-results";
				var googleSearchFormName = "cse-search-box";
				var googleSearchFrameWidth = 600;
				var googleSearchFrameHeight = 1300;
				var googleSearchDomain = "www.google.com";
				var googleSearchPath = "/cse";
			</script>
			<script type="text/javascript" src="http://www.google.com/afsonline/show_afs_search.js"></script>
	HTML
end
