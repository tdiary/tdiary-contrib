# -*- coding: utf-8; -*-
#
# default HTML header
#
add_header_proc do
	if /^(form|edit|preview|showcomment)$/ =~ @mode then
		%Q[<script src="js/draft.js" type="text/javascript"></script>]
	else
		''
	end
end

add_edit_proc do
	<<-EOS
	<div class="draft">
		下書き:
		<select name="drafts"></select>
		<button type="button" id="draft_load">読み込み</button>
	</div>
	EOS
end
