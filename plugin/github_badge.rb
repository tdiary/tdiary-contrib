# Github Badge, by drnic plugin.
# http://drnicjavascript.rubyforge.org/github_badge/
#
# usage:
#   github_badge(github_username)
#     - github_username: user name on github.com
#
# Copyright (c) 2008 KAKUTANI Shintaro <http://kakutani.com/>
# Distributed under the GPL

def github_badge( github_username, list_length = 10, github_head = "div", github_theme = "white", github_title = "My Projects", show_all = "Show all" )
	return (<<-EOS).chomp
<div id="github-badge"></div>
<script type="text/javascript" charset="utf-8">
  GITHUB_USERNAME="#{ github_username }";
  GITHUB_LIST_LENGTH=#{list_length};
  GITHUB_THEME="#{github_theme}";
  GITHUB_TITLE="#{github_title}"
  GITHUB_SHOW_ALL = "Show all"
</script>
<script src="http://drnicjavascript.rubyforge.org/github_badge/dist/github-badge-launcher.js" type="text/javascript"></script>
	EOS
end
