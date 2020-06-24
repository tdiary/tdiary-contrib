#
# twitter plugin is deprecate
#
add_body_leave_proc do |date|
	if @mode == 'preview'
		%Q[<p class="message">twitter plugin was deprecated.</p>]
	else
		''
	end
end
