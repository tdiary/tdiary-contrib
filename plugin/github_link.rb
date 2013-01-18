def gh_link(gh_identifier)
	text = gh_identifier.split('/').last
	id_and_name, number = gh_identifier.split('#')

	url = "https://github.com/#{id_and_name}"
	url = url + "/issues/#{number}" if number

	"<a href='#{url}'>#{text}</a>"
end
