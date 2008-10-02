# Github Badge, by drnic plugin.
# http://drnicjavascript.rubyforge.org/github_badge/
#
# usage:
#   github_badge(username, list_length, head, theme, title, show_all)
#     - username:    user name on github.com
#     - list_length: project list length
#     - theme:       specify theme for badge. "white" or "black".
#     - title:       top text display on the badge.
#     - show_all:    'Show All' message.
#
# Copyright (c) 2008 KAKUTANI Shintaro <http://kakutani.com/>
# Distributed under the GPL

def github_badge( username, list_length = 10, head = "div", theme = "white", title = "My Projects", show_all = "Show all" )
	return (<<-EOS).chomp
<div id="github-badge"></div>
<script type="text/javascript" charset="utf-8">
  GITHUB_USERNAME="#{ username }";
  GITHUB_LIST_LENGTH=#{ list_length };
  GITHUB_THEME="#{ theme }";
  GITHUB_TITLE="#{ title }"
  GITHUB_SHOW_ALL = "#{ show_all }"
</script>
<script src="http://drnicjavascript.rubyforge.org/github_badge/dist/github-badge-launcher.js" type="text/javascript"></script>
	EOS
end
