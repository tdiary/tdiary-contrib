add_conf_proc( 'comment_size' , @comment_size_conf, 'security') do
	if @mode == 'saveconf' then
		@conf['comment.size'] = @cgi.params['comment.size'][0]
	end
	@conf['comment.size'] = 0 unless @conf['comment.size']

	result = <<-HTML
	<h3>#{@comment_size}</h3>
	<p>#{@comment_size_desc}</p>
	<p><input name="comment.size" value="#{@conf['comment.size']}">Bytes</p>
	HTML
end
