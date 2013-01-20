def gh_link(gh_identifier, text=nil)
	text = gh_identifier.split('/').last if text.nil?
	id_and_name, number = gh_identifier.split('#')

	url = "https://github.com/#{id_and_name}"
	url = url + "/issues/#{number}" if number

	"<a href='#{url}'>#{h text}</a>"
end
